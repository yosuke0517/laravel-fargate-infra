// ここに書くだけではfoobarでは使用できない（foobarでシンボリックリンクを作成する必要がある）
locals {
  name_prefix = "${local.system_name}-${local.env_name}"
  system_name = "example"
  env_name    = "prod"
}
