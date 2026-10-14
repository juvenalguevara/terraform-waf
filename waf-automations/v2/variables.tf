variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically something like `module.label`."
}

variable "scanners_and_probes_enabled" {
  description = "Enable Scanners and Probes Protection"
  type        = bool
  default     = true
}

variable "scanners_and_probes_ipset" {
  description = "Scanners and Probes WAFv2 Blacklist IP Set name"
  default     = null
}

# HTTP Flood protection requires WAF logging WebACL info to be enabled.
# Since this feature still not implemented, parameter set to `false` by default.
variable "flood_protection_enabled" {
  description = "Enable HTTP Flood Attack Protection"
  type        = bool
  default     = false
}

variable "flood_protection_ipset" {
  description = "HTTP Flood Protection WAFv2 Blacklist IP Set name"
  default     = null
}

variable "reputation_lists_enabled" {
  description = "Blacklist based on thirt-party reputation lists (spamhaus, torproject, emergingthreats)"
  type        = bool
  default     = true
}

variable "reputation_lists_ipset" {
  description = "Reputation Lists WAFv2 Blacklist IP Set name"
  default     = null
}

variable "default_blacklist_ipset" {
  description = "Default WAFv2 Blacklist IP Set resource name"
  default     = null
}

variable "s3_events_enabled" {
  description = "Create S3 events to trigger WAF Security Autoamtions lambdas once log files uploads"
  type        = bool
  default     = false
}

variable "s3_events_filters" {
  description = "Filters for S3 events; see README `Usage` section for details"
  type        = list
  default     = [{}]
}

variable "waf_scope" {
  description = "WAF scope; available values are `CLOUDFRONT` or `REGIONAL`"
  default     = "CLOUDFRONT"
}

variable "waf_region" {
  description = "The AWS Region which will be used for the WAFv2 API calls; set to `us-east-1` for `CLOUDFRONT` scope"
  default     = "us-east-1"
}

variable "waf_block_period" {
  description = "Period to block malicous IP addresses (in minutes)"
  type        = number
  default     = 240
}

variable "waf_log_bucket" {
  description = "S3 Bucket name where WAF WebACL logs are stored; required for HTTP Flood Protection"
  default     = null
}

variable "lambda_source_bucket" {
  description = "S3 bucket name where WAF Security Automations source packages are stored"
  default     = "hs-lambda-functions"
}

variable "lambda_source_path" {
  description = "Path in the S3 bucket to WAF Security Automations source packages"
  default     = null
}

variable "lambda_source_version" {
  description = "WAF Security Automation vesion to deploy"
  default     = "latest"
}

variable "lambda_source_package_name" {
  description = "Lambda functions package name map"
  type        = object({ log_parser = string, reputation_lists = string })
  default     = { log_parser = "log_parser.zip", reputation_lists = "reputation_lists_parser.zip" }
}

variable "lambda_logging_level" {
  description = "Lambda function logging level"
  default     = "INFO"
}

variable "access_log_bucket" {
  description = "CloudFront/ALB application access logs bucket name; requiried for Scanners and Probes Protection"
}

variable "access_log_type" {
  description = "Application access log type; available values are `cloudfront` or `alb`; required for HTTP Flood Protection"
  default     = "cloudfront"
}

variable "access_log_policies" {
  description = "Custom policies for application access logs"
  type        = list(object({ UniqueName = string, ErrorCodesRegex = string, UriPathRegex = string, errorThreshold = number }))
  default     = []
}

variable "request_threshold" {
  description = "Maximum acceptable requests per 5-minute period per IP address for HTTP Flood Protection"
  type        = number
  default     = 100
}

variable "error_threshold" {
  description = "Maximum acceptable bad requests per minute per IP for Scanners and Probes Protection"
  type        = number
  default     = 50
}
