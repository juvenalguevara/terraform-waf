locals {
  count = var.enabled ? 1 : 0

  basic_auth_statement = {
    action = "allow"
    byte_match_statement = {
      field_to_match = {
        single_header = {
          name = "authorization"
        }
      }
      positional_constraint = "EXACTLY"
      search_string         = "Basic ${var.basic_auth_string}"
      text_transformation = {
        priority = 1
        type     = "NONE"
      }
    }
  }
  header_match_statements = concat(var.basic_auth_string != "" ? [local.basic_auth_statement] : [], [])
}
