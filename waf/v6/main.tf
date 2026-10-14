resource "aws_wafv2_web_acl" "default" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf
  tags     = var.label.tags

  name        = module.label.id
  scope       = "CLOUDFRONT"
  description = var.wafv2_description != "" ? var.wafv2_description : "${module.label.id}-webacl"

  default_action {
    dynamic "allow" {
      for_each = var.default_action_block ? [] : [1]
      content {}
    }

    dynamic "block" {
      for_each = var.default_action_block ? [1] : []
      content {}
    }
  }

  rule {
    name     = format("rule-1-%s", module.label_allowed_ips.id)
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = element(concat(aws_wafv2_ip_set.allowed_ips.*.arn), 0)
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics
      metric_name                = format("%s-rule-metric", module.label_allowed_ips.id)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = format("rule-2-%s", module.label_blocked_ips.id)
    priority = 2

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = element(concat(var.blocked_ips.*.arn), 0)
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics
      metric_name                = format("%s-rule-metric", module.label_blocked_ips.id)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = format("rule-3-%s", module.label_scanners_and_probes_blocked_ips.id)
    priority = 3

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = element(concat(var.scanners_probes_list.*.arn), 0)
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics
      metric_name                = format("%s-rule-metric", module.label_scanners_and_probes_blocked_ips.id)
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = format("rule-4-%s", module.label_reputation_lists.id)
    priority = 4

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = element(concat(var.reputation_list.*.arn), 0)
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics
      metric_name                = format("%s-rule-metric", module.label_reputation_lists.id)
      sampled_requests_enabled   = false
    }
  }

  dynamic "rule" {
    for_each = local.header_match_statements
    iterator = rule

    content {
      name     = format("rule-5-%s", module.label_header_authentication.id)
      priority = 5

      action {
        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = length(lookup(rule.value, "byte_match_statement", {})) == 0 ? [] : [lookup(rule.value, "byte_match_statement", {})]
          iterator = byte_match_statement

          content {
            dynamic "field_to_match" {
              for_each = length(lookup(byte_match_statement.value, "field_to_match", {})) == 0 ? [] : [lookup(byte_match_statement.value, "field_to_match", {})]
              iterator = field_to_match

              content {
                dynamic "single_header" {
                  for_each = length(lookup(field_to_match.value, "single_header", {})) == 0 ? [] : [lookup(field_to_match.value, "single_header", {})]
                  iterator = single_header

                  content {
                    name = lookup(single_header.value, "name")
                  }
                }

                # if we want to support more fields we just need to add the rules in here, for now is just single_header. Example:
                # dynamic "all_query_arguments" {
                #   for_each = length(lookup(rule.value, "all_query_arguments", {})) == 0 ? [] : [lookup(rule.value, "all_query_arguments", {})]
                #   content {}
                # }
              }
            }

            positional_constraint = lookup(byte_match_statement.value, "positional_constraint")
            search_string         = lookup(byte_match_statement.value, "search_string")

            dynamic "text_transformation" {
              for_each = length(lookup(byte_match_statement.value, "text_transformation", {})) == 0 ? [] : [lookup(byte_match_statement.value, "text_transformation", {})]
              iterator = text_transformation

              content {
                priority = lookup(text_transformation.value, "priority")
                type     = lookup(text_transformation.value, "type")
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(local.header_match_statements) == 0 ? [] : [1]

        content {
          cloudwatch_metrics_enabled = var.cloudwatch_metrics
          metric_name                = format("%s-header-match-rule-metric", module.label_header_authentication.id)
          sampled_requests_enabled   = false
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.corp_subnets != null ? [1] : []
    iterator = rule

    content {
      name     = format("rule-6-%s", module.label_corp_subnets.id)
      priority = 6

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = element(concat(var.corp_subnets.*.arn), 0)
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_corp_subnets.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.external_subnets != null ? [1] : []
    iterator = rule

    content {
      name     = format("rule-7-%s", module.label_external_subnets.id)
      priority = 7

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = element(concat(var.external_subnets.*.arn), 0)
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_external_subnets.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.sauce_labs_subnets != null ? [1] : []
    iterator = rule

    content {
      name     = format("rule-8-%s", module.label_sauce_labs_subnets.id)
      priority = 8

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = element(concat(var.sauce_labs_subnets.*.arn), 0)
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_sauce_labs_subnets.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.auth0_subnets != null ? [1] : []
    iterator = rule

    content {
      name     = format("rule-9-%s", module.label_auth0_subnets.id)
      priority = 9

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = element(concat(var.auth0_subnets.*.arn), 0)
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_auth0_subnets.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules_crs_mode != "disabled" ? [1] : []
    iterator = rule

    content {
      name     = format("rule-10-%s", module.label_aws_managed_rule_common_rule_set.id)
      priority = 10

      override_action {
        dynamic "count" {
          for_each = var.managed_rules_crs_mode == "count" ? [1] : []
          content {}
        }

        dynamic "none" {
          for_each = var.managed_rules_crs_mode == "block" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_aws_managed_rule_common_rule_set.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules_admin != "disabled" ? [1] : []
    iterator = rule

    content {
      name     = format("rule-11-%s", module.label_aws_managed_rules_admin.id)
      priority = 11

      override_action {
        dynamic "count" {
          for_each = var.managed_rules_admin == "count" ? [1] : []
          content {}
        }

        dynamic "none" {
          for_each = var.managed_rules_admin == "block" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAdminProtectionRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_aws_managed_rules_admin.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules_sql != "disabled" ? [1] : []
    iterator = rule

    content {
      name     = format("rule-12-%s", module.label_aws_managed_sql.id)
      priority = 12

      override_action {
        dynamic "count" {
          for_each = var.managed_rules_sql == "count" ? [1] : []
          content {}
        }

        dynamic "none" {
          for_each = var.managed_rules_sql == "block" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_aws_managed_sql.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules_ip != "disabled" ? [1] : []
    iterator = rule

    content {
      name     = format("rule-13-%s", module.label_aws_managed_rules_ip.id)
      priority = 13

      override_action {
        dynamic "count" {
          for_each = var.managed_rules_ip == "count" ? [1] : []
          content {}
        }

        dynamic "none" {
          for_each = var.managed_rules_ip == "block" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAnonymousIpList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_aws_managed_rules_ip.id)
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.managed_rules_iprep != "disabled" ? [1] : []
    iterator = rule

    content {
      name     = format("rule-14-%s", module.label_aws_managed_rules_ip_reputation.id)
      priority = 14

      override_action {
        dynamic "count" {
          for_each = var.managed_rules_iprep == "count" ? [1] : []
          content {}
        }

        dynamic "none" {
          for_each = var.managed_rules_iprep == "block" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.cloudwatch_metrics
        metric_name                = format("%s-rule-metric", module.label_aws_managed_rules_ip_reputation.id)
        sampled_requests_enabled   = false
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics
    metric_name                = format("%s-metric-name", module.label.id)
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_ip_set" "allowed_ips" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_allowed_ips.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips
  tags               = module.label_allowed_ips.tags
  description        = "Allowed IPs list"
}

resource "aws_wafv2_web_acl_logging_configuration" "wafv2_logging" {
  count    = var.enabled && length(var.log_destination_configs) > 0 ? 1 : 0
  provider = aws.waf

  log_destination_configs = var.log_destination_configs
  resource_arn            = aws_wafv2_web_acl.default[0].arn
}
