resource "aws_nat_gateway" "this" {
  # 三項演算子でnat gatewayが作成される数を制御
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}

  # NAT ゲートウェイに紐付けるElastic IP のid を指定
  allocation_id = aws_eip.nat_gateway[each.key].id
  # NAT ゲートウェイを紐付けるサブネットのid を指定
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-${each.key}"
  }
}