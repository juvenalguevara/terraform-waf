module "label" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["wafv2"]
}

module "label_allowed_ips" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["allowed", "ips"]
}

module "label_blocked_ips" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["blocked", "ips"]
}

module "label_corp_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["corp", "subnets"]
}

module "label_external_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["external", "subnets"]
}

module "label_sauce_labs_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["sauce", "labs", "subnets"]
}

module "label_auth0_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["auth0", "subnets"]
}

module "label_scanners_and_probes_blocked_ips" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["scanners", "probes"]
}

module "label_reputation_lists" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["reputation", "lists"]
}

module "label_header_authentication" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["header", "authentication"]
}

module "label_aws_managed_rule_common_rule_set" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["common", "rule", "set"]
}

module "label_aws_managed_rules_admin" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["admin"]
}

module "label_aws_managed_sql" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["sql", "injection"]
}

module "label_aws_managed_rules_ip" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["anonymous", "ip", "list"]
}

module "label_aws_managed_rules_ip_reputation" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["aws", "ip", "reputation", "list"]
}
