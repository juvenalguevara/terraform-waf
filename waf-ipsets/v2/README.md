# Web Application Firewall (WAF) v2

A Terraform module to create WAF IPSets that will be used as global resources for different WAF's

## Important notes
The following IPSets will be created as part of this module:
* corp_subnets_ipset
* external_subnets_ipset
* sauce_labs_subnets_ipset
* auth0_subnets_ipset
* blocked_ipset  

## Examples

```
module "global_waf_ipsets" {
  source      = "../../../modules/site/waf-ipsets/v3"
  environment = local.env
  role_name   = local.role_name

  providers = {
    aws     = aws
    aws.waf = aws.east
  }
}
```

## History

### v1
- Initial module WAF IPsets v1

### v2
- Use v2 of hs_ips module

### v3
- v3 to support new label modules

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `blacklist_ips` |Blacklist ips provided by OPS team |list(string) | `[]` | no |
| `enabled` |Whether to create the resources. Set to `false` to prevent the module from creating any resources |bool | `true` | no |
| `label` |Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`. | | `` | yes |

## Outputs
| Name | Description |
|------|-------------|
| `global_auth0_subnet_ipset` | The auth0 subnet ipset resource. |
| `global_blocked_ipset` | The blocked ipset resource. |
| `global_corp_subnet_ipset` | The corp subnet ipset resource. |
| `global_external_subnet_ipset` | The external subnet ipset resource. |
| `global_sauce_labs_subnet_ipset` | The sauce labs subnet ipset resource. |

Managed Resources
-----------------
* `aws_wafv2_ip_set.auth0_subnets`
* `aws_wafv2_ip_set.blocked_ipset`
* `aws_wafv2_ip_set.corp_subnets`
* `aws_wafv2_ip_set.external_subnets`
* `aws_wafv2_ip_set.sauce_labs_subnets`

Data Resources
--------------
* `data.aws_caller_identity.current`
* `data.aws_region.current`

Child Modules
-------------
* `hs_ips` from `../../../../modules/site/hs_ips/v3`
* `label_auth0_subnets` from `../../../../modules/site/label/v1`
* `label_blocked_ips` from `../../../../modules/site/label/v1`
* `label_corp_subnets` from `../../../../modules/site/label/v1`
* `label_external_subnets` from `../../../../modules/site/label/v1`
* `label_sauce_labs_subnets` from `../../../../modules/site/label/v1`
<!-- END OF TERRAFORM-DOCS HOOK -->
