# Web Application Firewall (WAF) v2

A Terraform module to create WAF v2 that helps to protect HS web applications against common web exploits that may affect availability, compromise security, or consume excessive resourcess.
Creates WAFv2 Web ACL resources including the following rules:
* allowed-ips-rule
* blocked-ips-rule
* allowed_ips  
* blocked_ips  
* basic_auth_string  
* reputation_list  
* scanners_probes_list
* enabled  
* default_action_block
* wafv2_description  

## Important notes
* Currently, this module creates WAFv2 Web ACL resources for Cloudfront distributions ONLY.
* IMPORTANT: the only dynamic rule supported at this point is
  * The rule byte match statement provides the bytes to search in the single_header argument. The bytes to search for are typically a string that corresponds with ASCII characters. If the request contains the matching condition the request will be allowed or blocked depending the dynamic rule entry.
  * The `header_match_statements` block supports the following arguments:
    * action: (Required) allow or block
    * byte_match_statement: (Required) A rule statement that defines a string match search for AWS WAF to apply to web request. The byte_match_statement block supports the following arguments:
      * field_to_match  The part of a web request that you want AWS WAF to inspect.
        * single_header - (Required) Inspect a single header.
          * Inspect a single header. Provide the name of the header to inspect, for example, User-Agent or Referer (provided as lowercase strings). The single_header block supports the following arguments:
          * name - (Optional) The name of the query header to inspect. This setting must be provided as lower case characters.
    * positional_constraint - (Required) The area within the portion of a web request that you want AWS WAF to search for search_string. Valid values include the following: EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD.
    * search_string - (Required) A string value that you want AWS WAF to search for. AWS WAF searches only in the part of web requests that you designate for inspection in field_to_match. The maximum length of the value is 50 bytes.
    * text_transformation - (Required) Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection. See Text Transformation below for details.


## Examples

WAF v2 with an optional `header_match_statements` and Basic Auth are enabled:
```

module "corp_subnets_wafv2" {
  source      = "../../../modules/site/waf/v5"

  allowed_ips          = local.wafv2_config.allowed_ips
  blocked_ips          = local.wafv2_config.blocked_ips
  basic_auth_string    = local.wafv2_config.basic_auth_string
  reputation_list      = local.wafv2_config.reputation_list
  scanners_probes_list = local.wafv2_config.scanners_probes_list
  enabled              = local.wafv2_config.enabled
  default_action_block = local.wafv2_config.default_action_block
  wafv2_description    = local.wafv2_config.wafv2_description

  providers = {
    aws     = aws
    aws.waf = aws.east
  }
}


```

## History

### v6
- v6 add suport for AWS Managed Rules

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `allowed_ips` |List of allowed IP addresses | | `[]` | no |
| `auth0_subnets` |Auth0 Subnets IpSet | | `` | yes |
| `basic_auth_string` |Basic authentication string: base64 encoded <username:password> pair | | `` | no |
| `blocked_ips` |Blocked IP addresses Ipset | | `` | yes |
| `cloudwatch_metrics` |Whether to create CloudWatch metrics or not |bool | `true` | no |
| `corp_subnets` |Corp Subnets IpSet | | `` | yes |
| `default_action_block` |Set to true `true` for WAF to block requests by default | | `` | yes |
| `enabled` |Whether to create the resources. Set to `false` to prevent the module from creating any resources |bool | `true` | no |
| `external_subnets` |External Subnets | | `` | yes |
| `label` |Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`. | | `` | yes |
| `log_destination_configs` |The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported. |list(string) | `[]` | no |
| `managed_rules_admin` |Admin protection rule group contains rules that allow you to block external access to exposed admin pages. |string | `disabled` | no |
| `managed_rules_crs_mode` |Baseline managed rule group to provide general protection against a wide variety of common threats |string | `disabled` | no |
| `managed_rules_ip` |Anonymous IP list rule group contains rules to block request from services that allow the obfuscation of viewer identity |string | `disabled` | no |
| `managed_rules_iprep` |IP Reputation list rule group contains rules that are absed on Amazon internal threat intelligence |string | `disabled` | no |
| `managed_rules_sql` |SQL database rule group contains rule to block request patterns associated with exploitation of SQL databases |string | `disabled` | no |
| `reputation_list` |Reputation List Ipset | | `` | yes |
| `sauce_labs_subnets` |Sauce Labs Subnets IpSet | | `` | yes |
| `scanners_probes_list` |Scanners Probes List Ipset | | `` | yes |
| `wafv2_description` |WAFv2 description | | `` | no |

## Outputs
| Name | Description |
|------|-------------|
| `waf` | The WAFv2 resource. |
| `web_acl` | WebACL resource object (WAFv2) |

Managed Resources
-----------------
* `aws_wafv2_ip_set.allowed_ips`
* `aws_wafv2_web_acl.default`
* `aws_wafv2_web_acl_logging_configuration.wafv2_logging`

Data Resources
--------------
* `data.aws_caller_identity.current`
* `data.aws_region.current`

Child Modules
-------------
* `label` from `../../../../modules/site/label/v1`
* `label_allowed_ips` from `../../../../modules/site/label/v1`
* `label_auth0_subnets` from `../../../../modules/site/label/v1`
* `label_aws_managed_rule_common_rule_set` from `../../../../modules/site/label/v1`
* `label_aws_managed_rules_admin` from `../../../../modules/site/label/v1`
* `label_aws_managed_rules_ip` from `../../../../modules/site/label/v1`
* `label_aws_managed_rules_ip_reputation` from `../../../../modules/site/label/v1`
* `label_aws_managed_sql` from `../../../../modules/site/label/v1`
* `label_blocked_ips` from `../../../../modules/site/label/v1`
* `label_corp_subnets` from `../../../../modules/site/label/v1`
* `label_external_subnets` from `../../../../modules/site/label/v1`
* `label_header_authentication` from `../../../../modules/site/label/v1`
* `label_reputation_lists` from `../../../../modules/site/label/v1`
* `label_sauce_labs_subnets` from `../../../../modules/site/label/v1`
* `label_scanners_and_probes_blocked_ips` from `../../../../modules/site/label/v1`
<!-- END OF TERRAFORM-DOCS HOOK -->
