resource "aws_wafv2_ip_set" "corp_subnets" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_corp_subnets.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = module.hs_ips.corp_subnets
  tags               = module.label_corp_subnets.tags
  description        = "Allowed Corp Subnets IPs"
}

resource "aws_wafv2_ip_set" "external_subnets" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_external_subnets.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.external_subnets
  tags               = module.label_external_subnets.tags
  description        = "Allowed External Subnets IPs"
}

resource "aws_wafv2_ip_set" "sauce_labs_subnets" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_sauce_labs_subnets.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.sauce_labs_subnets
  tags               = module.label_sauce_labs_subnets.tags
  description        = "Allowed Sauce Labs Subnets IPs"
}

resource "aws_wafv2_ip_set" "auth0_subnets" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_auth0_subnets.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.auth0_subnets
  tags               = module.label_auth0_subnets.tags
  description        = "Allowed Auth0 Subnets IPs"
}

resource "aws_wafv2_ip_set" "blocked_ipset" {
  count    = var.enabled ? 1 : 0
  provider = aws.waf

  name               = module.label_blocked_ips.id
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.blacklist_ips
  tags               = module.label_blocked_ips.tags
  description        = "Blocked IPs list"
}
