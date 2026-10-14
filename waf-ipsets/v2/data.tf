data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "hs_ips" {
  source = "../../../../modules/site/hs_ips/v3"
}
