module "label_corp_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["corp", "subnets", "ipset"]
}

module "label_external_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["external", "subnets", "ipset"]
}

module "label_sauce_labs_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["sauce", "labs", "subnets", "ipset"]
}

module "label_auth0_subnets" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["auth0", "subnets", "ipset"]
}

module "label_blocked_ips" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["blocked", "ips", "ipset"]
}
