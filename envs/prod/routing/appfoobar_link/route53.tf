data "aws_route53_zone" "this" {
  name = "yosukedev.link"
}

# 検証用のCNAMEコードの作成以下参照
# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation#dns-validation-with-route-53
resource "aws_route53_record" "certificate_validation" {
  for_each = {
  for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    type   = dvo.resource_record_type
    record = dvo.resource_record_value
  }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.this.id
}

# ALIASレコード（Aレコード）の作成
resource "aws_route53_record" "root_a" {
  count = var.enable_alb ? 1 : 0
  # レコードの名前
  name    = data.aws_route53_zone.this.name
  # ALIAS
  type    = "A"
  # レコードが属するホストゾーンのID を指定
  zone_id = data.aws_route53_zone.this.zone_id

  # ALIASレコードの場合aliasブロックを指定する
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
}