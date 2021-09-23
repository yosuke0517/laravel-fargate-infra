module "nginx" {
  source = "../../../../modules/ecr" // モジュールのパス

  name = "${local.name_prefix}-${local.service_name}-nginx" // モジュールに注入する変数（デフォルト設定されている変数は省略可能
}

module "php" {
  source = "../../../../modules/ecr"

  name = "${local.name_prefix}-${local.service_name}-php"
}
