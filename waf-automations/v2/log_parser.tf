data "aws_iam_policy_document" "log_parser" {
  statement {
    sid       = "CWMetricsAccess"
    effect    = "Allow"
    actions   = ["cloudwatch:GetMetricStatistics"]
    resources = ["*"]
  }

  statement {
    sid    = "CWLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }

  dynamic "statement" {
    for_each = local.log_parser_enabled ? local.log_parser_policy_statements : []

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

locals {
  log_parser_policy_statements = [
    {
      sid    = "S3LogsAccess"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = flatten([
        var.scanners_and_probes_enabled ? ["arn:aws:s3:::${var.access_log_bucket}/*"] : [],
        var.flood_protection_enabled ? ["arn:aws:s3:::${var.waf_log_bucket}/*"] : []
      ])
    },
    {
      sid    = "WAFv2ReadAccess"
      effect = "Allow"
      actions = [
        "wafv2:GetIPSet",
        "wafv2:ListIPSets",
        "wafv2:ListWebACLs"
      ]
      resources = ["*"]
    },
    {
      sid     = "WAFv2WriteAccess"
      effect  = "Allow"
      actions = ["wafv2:UpdateIPSet"]
      resources = distinct(flatten([
        var.flood_protection_enabled ? [local.flood_protection_ipset.arn] : [],
        var.scanners_and_probes_enabled ? [local.scanners_and_probes_ipset.arn] : [],
      ]))
    }
  ]
}

data "aws_s3_bucket_object" "log_parser" {
  count  = local.log_parser_count
  bucket = var.lambda_source_bucket
  key    = "${local.lambda_source_path}/${var.lambda_source_package_name.log_parser}"
}

module "log_parser" {
  source = "../../lambda/v7"
  label  = module.label_log_parser
  count  = local.log_parser_count

  description              = "AWS WAF Security Automations - Access Logs Parser"
  runtime                  = "python3.8"
  handler                  = "log-parser.lambda_handler"
  s3_bucket                = try(data.aws_s3_bucket_object.log_parser[0].bucket, null)
  s3_key                   = try(data.aws_s3_bucket_object.log_parser[0].key, null)
  source_code_hash         = try(filebase64sha256(data.aws_s3_bucket_object.log_parser[0].key), null)
  iam_role_policy_document = data.aws_iam_policy_document.log_parser.json
  variables                = local.log_parser_vars
  timeout                  = 300
  memory_size              = 512
}

resource "aws_lambda_permission" "log_parser" {
  count          = local.log_parser_count
  action         = "lambda:InvokeFunction"
  principal      = "s3.amazonaws.com"
  source_arn     = "arn:aws:s3:::${var.access_log_bucket}"
  function_name  = module.log_parser[0].function.arn
  source_account = data.aws_caller_identity.current.id
}

resource "aws_s3_bucket_notification" "log_parsers" {
  count  = local.log_parser_s3_events_count
  bucket = var.access_log_bucket

  dynamic "lambda_function" {
    for_each = var.s3_events_filters

    content {
      events              = try(lambda_function.value.events, ["s3:ObjectCreated:*"])
      lambda_function_arn = try(lambda_function.value.lambda_function_arn, module.log_parser[0].function.arn)
      filter_prefix       = try(lambda_function.value.filter_prefix, null)
      filter_suffix       = try(lambda_function.value.filter_suffix, null)
    }
  }
}
