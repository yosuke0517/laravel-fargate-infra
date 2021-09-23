module "nginx" {
  source = "../../../../modules/ecr" // モジュールのパス

  name = "example-prod-foobar-nginx" // モジュールに注入する変数（デフォルト設定されている変数は省略可能
}
