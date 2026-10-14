locals {
  count = var.enabled ? 1 : 0

  # WAF v2 subnets and configs
  external_subnets = [
    # Braze
    "206.252.203.38/32",
  ]

  sauce_labs_subnets = [
    # US 1
    "162.222.72.0/21",
    # US 2
    "66.85.48.0/21",
    # Europe
    "185.94.24.0/22",
  ]

  auth0_subnets = [
    # IP 1
    "35.167.74.121/32",
    # IP 2
    "35.166.202.113/32",
    # IP 3
    "35.160.3.103/32",
    # IP 4
    "54.183.64.135/32",
    # IP 5
    "54.67.77.38/32",
    # IP 6
    "54.67.15.170/32",
    # IP 7
    "54.183.204.205/32",
  ]

}
