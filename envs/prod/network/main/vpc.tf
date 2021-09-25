# リソースを1 つだけ作成するような場合は、this と付ける
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  # プライベートホストゾーンでの名前解決を有効にするため以下をtrueにする
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-main"
  }
}