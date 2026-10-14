data "aws_iam_policy_document" "reputation_lists" {
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
    for_each = var.reputation_lists_enabled ? local.reputation_lists_policy_statements : []

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

locals {
  reputation_lists_policy_statements = [
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
      sid       = "WAFv2WriteAccess"
      effect    = "Allow"
      actions   = ["wafv2:UpdateIPSet"]
      resources = [var.reputation_lists_enabled ? local.reputation_lists_ipset.arn : "*"]
    }
  ]
}

data "aws_s3_bucket_object" "reputation_lists" {
  count  = local.reputation_lists_count
  bucket = var.lambda_source_bucket
  key    = "${local.lambda_source_path}/${var.lambda_source_package_name.reputation_lists}"
}

module "reputation_lists" {
  source = "../../lambda/v7"
  label  = module.label_reputation_lists
  count  = local.reputation_lists_count

  description              = "AWS WAF Security Automations - Reputation Lists"
  runtime                  = "python3.8"
  handler                  = "reputation-lists.lambda_handler"
  s3_bucket                = try(data.aws_s3_bucket_object.reputation_lists[0].bucket, null)
  s3_key                   = try(data.aws_s3_bucket_object.reputation_lists[0].key, null)
  source_code_hash         = try(filebase64sha256(data.aws_s3_bucket_object.reputation_lists[0].key), null)
  iam_role_policy_document = data.aws_iam_policy_document.reputation_lists.json
  variables                = local.reputation_lists_vars
  timeout                  = 300
  memory_size              = 512

}

resource "aws_lambda_permission" "reputation_lists" {
  count         = local.reputation_lists_count
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  source_arn    = try(aws_cloudwatch_event_rule.reputation_lists[0].arn, null)
  function_name = module.reputation_lists[0].function.arn
}

resource "aws_cloudwatch_event_rule" "reputation_lists" {
  count               = local.reputation_lists_count
  name                = module.label_reputation_lists.id
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "reputation_lists" {
  count      = local.reputation_lists_count
  depends_on = [aws_cloudwatch_event_rule.reputation_lists]
  rule       = try(aws_cloudwatch_event_rule.reputation_lists[0].name, null)
  arn        = module.reputation_lists[0].function.arn

  input = jsonencode({
    URL_LIST                 = local.reputation_lists,
    IP_SET_ID_REPUTATIONV4   = local.reputation_lists_ipset.id
    IP_SET_NAME_REPUTATIONV4 = local.reputation_lists_ipset.name
    SCOPE                    = var.waf_scope
  })
}
