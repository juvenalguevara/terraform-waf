output "log_parser" {
  description = "Access logs parser Lambda module"
  value       = module.log_parser
}

output "reputation_lists" {
  description = "Reputation lists parser Lambda module"
  value       = module.reputation_lists
}
