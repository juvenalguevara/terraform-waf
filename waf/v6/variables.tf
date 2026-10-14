variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}

variable "enabled" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "default_action_block" {
  description = "Set to true `true` for WAF to block requests by default"
}

variable "allowed_ips" {
  description = "List of allowed IP addresses"
  default     = []
}

variable "corp_subnets" {
  description = "Corp Subnets IpSet"
  default     = null
}

variable "external_subnets" {
  description = "External Subnets"
  default     = null
}

variable "sauce_labs_subnets" {
  description = "Sauce Labs Subnets IpSet"
  default     = null
}

variable "auth0_subnets" {
  description = "Auth0 Subnets IpSet"
  default     = null
}

variable "blocked_ips" {
  description = "Blocked IP addresses Ipset"
  default     = null
}

variable "cloudwatch_metrics" {
  type        = bool
  description = "Whether to create CloudWatch metrics or not"
  default     = true
}

# Base64 encoded username:password pair
# You may want to use the following commands to get one:
# - echo $username:$password | tr -d \\n | base64
# - echo $username:$password | tr -d \\n | openssl enc -base64
variable "basic_auth_string" {
  description = "Basic authentication string: base64 encoded <username:password> pair"
  default     = ""
}

variable "wafv2_description" {
  description = "WAFv2 description"
  default     = ""
}

variable "reputation_list" {
  description = "Reputation List Ipset"
}

variable "scanners_probes_list" {
  description = "Scanners Probes List Ipset"
}

variable "log_destination_configs" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported."
  default     = []
}

variable "managed_rules_crs_mode" {
  default     = "disabled"
  type        = string
  description = "Baseline managed rule group to provide general protection against a wide variety of common threats"
  validation {
    condition     = contains(["disabled", "count", "block"], var.managed_rules_crs_mode)
    error_message = "The managed_rules_crs_mode variable must have a valid value from (disabled,count,block)."
  }
}

variable "managed_rules_admin" {
  default     = "disabled"
  type        = string
  description = "Admin protection rule group contains rules that allow you to block external access to exposed admin pages."
  validation {
    condition     = contains(["disabled", "count", "block"], var.managed_rules_admin)
    error_message = "The managed_rules_admin variable must have a valid value from (disabled,count,block)."
  }
}

variable "managed_rules_sql" {
  default     = "disabled"
  type        = string
  description = "SQL database rule group contains rule to block request patterns associated with exploitation of SQL databases"
  validation {
    condition     = contains(["disabled", "count", "block"], var.managed_rules_sql)
    error_message = "The managed_rules_sql variable must have a valid value from (disabled,count,block)."
  }
}

variable "managed_rules_ip" {
  default     = "disabled"
  type        = string
  description = "Anonymous IP list rule group contains rules to block request from services that allow the obfuscation of viewer identity"
  validation {
    condition     = contains(["disabled", "count", "block"], var.managed_rules_ip)
    error_message = "The managed_rules_ip variable must have a valid value from (disabled,count,block)."
  }
}

variable "managed_rules_iprep" {
  default     = "disabled"
  type        = string
  description = "IP Reputation list rule group contains rules that are absed on Amazon internal threat intelligence"
  validation {
    condition     = contains(["disabled", "count", "block"], var.managed_rules_iprep)
    error_message = "The managed_rules_iprep variable must have a valid value from (disabled,count,block)."
  }
}
