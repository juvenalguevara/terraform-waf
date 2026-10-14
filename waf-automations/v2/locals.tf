locals {
  lambda_source_path = var.lambda_source_path == null ? "${var.label.environment}/aws-waf-security-automations/${var.lambda_source_version}" : var.lambda_source_path

  log_parser_enabled         = var.scanners_and_probes_enabled || var.flood_protection_enabled
  log_parser_count           = local.log_parser_enabled ? 1 : 0
  log_parser_s3_events_count = local.log_parser_enabled && var.s3_events_enabled ? 1 : 0

  scanners_and_probes_count = var.scanners_and_probes_enabled ? 1 : 0
  scanners_and_probes_ipset = var.scanners_and_probes_ipset != null ? var.scanners_and_probes_ipset : var.default_blacklist_ipset

  flood_protection_count = var.flood_protection_enabled ? 1 : 0
  flood_protection_ipset = var.flood_protection_ipset != null ? var.flood_protection_ipset : var.default_blacklist_ipset

  reputation_lists_count = var.reputation_lists_enabled ? 1 : 0
  reputation_lists_ipset = var.reputation_lists_ipset != null ? var.reputation_lists_ipset : var.default_blacklist_ipset

  access_log_policies = jsonencode({
    Policies = var.access_log_policies
  })

  log_parser_vars = merge(
    {
      ENV                                            = module.label_log_parser.environment
      ROLE                                           = module.label_log_parser.role_name
      STACK_NAME                                     = module.label_log_parser.id
      LOG_TYPE                                       = var.access_log_type
      SCOPE                                          = var.waf_scope
      WAF_REGION                                     = var.waf_region
      WAF_BLOCK_PERIOD                               = var.waf_block_period
      LOG_LEVEL                                      = var.lambda_logging_level
      CONFIG_JSON                                    = local.access_log_policies
      MAX_AGE_TO_UPDATE                              = 30
      LIMIT_IP_ADDRESS_RANGES_PER_IP_MATCH_CONDITION = 10000
      SEND_ANONYMOUS_USAGE_DATA                      = false
    },
    var.scanners_and_probes_enabled ? {
      APP_ACCESS_LOG_BUCKET         = var.access_log_bucket
      IP_SET_ID_SCANNERS_PROBESV4   = local.scanners_and_probes_ipset.id
      IP_SET_NAME_SCANNERS_PROBESV4 = local.scanners_and_probes_ipset.name
      ERROR_THRESHOLD               = var.error_threshold
    } : {},
    var.flood_protection_enabled ? {
      WAF_ACCESS_LOG_BUCKET    = var.waf_log_bucket
      IP_SET_ID_HTTP_FLOODV4   = local.flood_protection_ipset.id
      IP_SET_NAME_HTTP_FLOODV4 = local.flood_protection_ipset.name
      REQUEST_THRESHOLD        = var.request_threshold
    } : {}
  )

  reputation_lists = [
    { url = "https://www.spamhaus.org/drop/drop.txt" },
    { url = "https://www.spamhaus.org/drop/edrop.txt" },
    { url = "https://check.torproject.org/exit-addresses", prefix = "ExitAddress" },
    { url = "https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt" }
  ]

  reputation_lists_vars = var.reputation_lists_enabled ? {
    ENV                       = module.label_reputation_lists.environment
    ROLE                      = module.label_reputation_lists.role_name
    URL_LIST                  = jsonencode(local.reputation_lists)
    IP_SET_ID_REPUTATIONV4    = local.reputation_lists_ipset.id
    IP_SET_NAME_REPUTATIONV4  = local.reputation_lists_ipset.name
    SCOPE                     = var.waf_scope
    WAF_REGION                = var.waf_region
    LOG_LEVEL                 = var.lambda_logging_level
    SEND_ANONYMOUS_USAGE_DATA = false
  } : {}
}
