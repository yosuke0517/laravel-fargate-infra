resource "aws_acm_certificate" "root" {
  domain_name = data.aws_route53_zone.this.name

  validation_method = "DNS" # EMAILも指定可能

  tags = {
    Name = "${local.name_prefix}-yosukedev-link"
  }

  lifecycle {
    # 新しいリソースを作成して古いリソースを削除する（デフォルトは逆だけど↓が推奨）
    create_before_destroy = true
  }
}

# DNS検証（何かリソースを作成するワケではない）
# 検証が完了するとapplyが完了する
resource "aws_acm_certificate_validation" "root" {
  certificate_arn = aws_acm_certificate.root.arn
}