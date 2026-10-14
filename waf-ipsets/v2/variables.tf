variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}

variable "enabled" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "blacklist_ips" {
  type        = list(string)
  description = "Blacklist ips provided by OPS team"
  default     = []
}
