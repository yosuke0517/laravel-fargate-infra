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