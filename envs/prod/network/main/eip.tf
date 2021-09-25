# natgatewayにあてがうパブリックIP
resource "aws_eip" "nat_gateway" {
  # 三項演算子で判定: enable_nat_gatewayがtrueのときは、local.nat_gateway_azsを回してIP作成
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}

  vpc = true

  tags = {
    Name = "${aws_vpc.this.tags.Name}-nat-gateway-${each.key}"
  }
}