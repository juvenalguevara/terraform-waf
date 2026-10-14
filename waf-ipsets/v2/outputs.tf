
output "global_corp_subnet_ipset" {
  value       = var.enabled ? aws_wafv2_ip_set.corp_subnets[0] : null
  description = "The corp subnet ipset resource."
}

output "global_external_subnet_ipset" {
  value       = var.enabled ? aws_wafv2_ip_set.external_subnets[0] : null
  description = "The external subnet ipset resource."
}

output "global_sauce_labs_subnet_ipset" {
  value       = var.enabled ? aws_wafv2_ip_set.sauce_labs_subnets[0] : null
  description = "The sauce labs subnet ipset resource."
}

output "global_auth0_subnet_ipset" {
  value       = var.enabled ? aws_wafv2_ip_set.auth0_subnets[0] : null
  description = "The auth0 subnet ipset resource."
}

output "global_blocked_ipset" {
  value       = var.enabled ? aws_wafv2_ip_set.blocked_ipset[0] : null
  description = "The blocked ipset resource."
}
