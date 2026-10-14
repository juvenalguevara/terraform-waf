output "web_acl" {
  value       = var.enabled ? aws_wafv2_web_acl.default[0] : null
  description = "WebACL resource object (WAFv2)"
}

output "waf" {
  value       = var.enabled ? aws_wafv2_web_acl.default[0] : null
  description = "The WAFv2 resource."
}
