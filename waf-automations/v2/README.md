# AWS WAF Security Automations

This module deploys Lambda functions to automate blacklists (WAFv2 IP set) populating:
- inspects requests to CloudFront distributions or Application Load Balancers, and blocks them using when applicable,
- updates blacklists using reputation lists.

This solution is based on Amazon-provided AWS WAF Security Automations version 3.0

## Usage

Setup `Scanners and Probes` and `Reputation Lists` protection:
```hcl
module "label" {
  source = "../../../modules/site/label/v1"
  ...
}

module "waf_automations" {
  source = "../../../modules/site/waf-automations/v2"
  label  = module.label

  scanners_and_probes_enabled = true
  scanners_and_probes_ipset   = aws_wafv2_ip_set.scanners_and_probes

  reputation_lists_enabled = true
  reputation_lists_ipset   = aws_wafv2_ip_set.reputation_lists

  s3_events_enabled = true
  s3_events_filters = [
    {
      filter_prefix       = "cloudfront/${local.env}-api"
      filter_suffix       = ".gz"
    },
    {
      filter_prefix       = "cloudfront/${local.env}-website"
      filter_suffix       = ".gz"
    }
  ]

  access_log_policies = [
    {
      UniqueName      = "Vouchers",
      ErrorCodesRegex = "^40[43]$",
      errorThreshold  = local.is_prod ? 20 : 500,
      UriPathRegex    = "^/subscription/vouchers/.*$"
    },
    {
      UniqueName      = "ActivityGroups",
      ErrorCodesRegex = "^403$",
      errorThreshold  = local.is_prod ? 100 : 500,
      UriPathRegex    = "^/content/activity-groups/.*$"
    }
  ]

  access_log_bucket    = data.terraform_remote_state.global.outputs.logging_bucket.id
  lambda_source_bucket = data.terraform_remote_state.s3.outputs.lambda_function_name
}
```

## References
- [AWS WAF Security Automations](https://aws.amazon.com/solutions/implementations/aws-waf-security-automations/)

## History

### v2
- Using label module `site/label/v1`
- Input `enabled` removed
- Lambda module updated: v4 --> v7

### v1
Initial WAF Security Automations module:
- Reputation Lists protection
- Scanners and Probes protection
- HTTP Flood protection


<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `access_log_bucket` |CloudFront/ALB application access logs bucket name; requiried for Scanners and Probes Protection | | `` | yes |
| `access_log_policies` |Custom policies for application access logs |list(object({ UniqueName = string, ErrorCodesRegex = string, UriPathRegex = string, errorThreshold = number })) | `[]` | no |
| `access_log_type` |Application access log type; available values are `cloudfront` or `alb`; required for HTTP Flood Protection | | `cloudfront` | no |
| `default_blacklist_ipset` |Default WAFv2 Blacklist IP Set resource name | | `` | yes |
| `error_threshold` |Maximum acceptable bad requests per minute per IP for Scanners and Probes Protection |number | `50` | no |
| `flood_protection_enabled` |Enable HTTP Flood Attack Protection |bool | `false` | no |
| `flood_protection_ipset` |HTTP Flood Protection WAFv2 Blacklist IP Set name | | `` | yes |
| `label` |Single `label` resource for setting context and tagging resources. Typically something like `module.label`. | | `` | yes |
| `lambda_logging_level` |Lambda function logging level | | `INFO` | no |
| `lambda_source_bucket` |S3 bucket name where WAF Security Automations source packages are stored | | `hs-lambda-functions` | no |
| `lambda_source_package_name` |Lambda functions package name map |object({ log_parser = string, reputation_lists = string }) | `map[log_parser:log_parser.zip reputation_lists:reputation_lists_parser.zip]` | no |
| `lambda_source_path` |Path in the S3 bucket to WAF Security Automations source packages | | `` | yes |
| `lambda_source_version` |WAF Security Automation vesion to deploy | | `latest` | no |
| `reputation_lists_enabled` |Blacklist based on thirt-party reputation lists (spamhaus, torproject, emergingthreats) |bool | `true` | no |
| `reputation_lists_ipset` |Reputation Lists WAFv2 Blacklist IP Set name | | `` | yes |
| `request_threshold` |Maximum acceptable requests per 5-minute period per IP address for HTTP Flood Protection |number | `100` | no |
| `s3_events_enabled` |Create S3 events to trigger WAF Security Autoamtions lambdas once log files uploads |bool | `false` | no |
| `s3_events_filters` |Filters for S3 events; see README `Usage` section for details |list | `[map[]]` | no |
| `scanners_and_probes_enabled` |Enable Scanners and Probes Protection |bool | `true` | no |
| `scanners_and_probes_ipset` |Scanners and Probes WAFv2 Blacklist IP Set name | | `` | yes |
| `waf_block_period` |Period to block malicous IP addresses (in minutes) |number | `240` | no |
| `waf_log_bucket` |S3 Bucket name where WAF WebACL logs are stored; required for HTTP Flood Protection | | `` | yes |
| `waf_region` |The AWS Region which will be used for the WAFv2 API calls; set to `us-east-1` for `CLOUDFRONT` scope | | `us-east-1` | no |
| `waf_scope` |WAF scope; available values are `CLOUDFRONT` or `REGIONAL` | | `CLOUDFRONT` | no |

## Outputs
| Name | Description |
|------|-------------|
| `log_parser` | Access logs parser Lambda module |
| `reputation_lists` | Reputation lists parser Lambda module |

Managed Resources
-----------------
* `aws_cloudwatch_event_rule.reputation_lists`
* `aws_cloudwatch_event_target.reputation_lists`
* `aws_lambda_permission.log_parser`
* `aws_lambda_permission.reputation_lists`
* `aws_s3_bucket_notification.log_parsers`

Data Resources
--------------
* `data.aws_caller_identity.current`
* `data.aws_iam_policy_document.log_parser`
* `data.aws_iam_policy_document.reputation_lists`
* `data.aws_region.current`
* `data.aws_s3_bucket_object.log_parser`
* `data.aws_s3_bucket_object.reputation_lists`

Child Modules
-------------
* `label_log_parser` from `../../../../modules/site/label/v1`
* `label_reputation_lists` from `../../../../modules/site/label/v1`
* `log_parser` from `../../lambda/v7`
* `reputation_lists` from `../../lambda/v7`
<!-- END OF TERRAFORM-DOCS HOOK -->
