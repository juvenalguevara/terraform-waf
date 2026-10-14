module "label_log_parser" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["log-parser"]
}

module "label_reputation_lists" {
  source     = "../../../../modules/site/label/v1"
  context    = var.label.context
  attributes = ["reputation-list"]
}
