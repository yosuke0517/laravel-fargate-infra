resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public"
  }
}

resource "aws_route" "internet_gateway_public" {
  destination_cidr_block = "0.0.0.0/0"
  # インターネットゲートウェイへのルートを作成
  gateway_id             = aws_internet_gateway.this.id
  # このルートを登録するルートテーブルのidを指定
  route_table_id         = aws_route_table.public.id
}

# ルートテーブルとサブネットの紐付け
resource "aws_route_table_association" "public" {
  for_each = var.azs
  # for_eachでa,cそれぞれのpublicに紐付け
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}

# プライベート
resource "aws_route_table" "private" {
  for_each = var.azs

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}

resource "aws_route" "nat_gateway_private" {
  # enable_nat_gatewayがfalseの場合は作成しない
  for_each = var.enable_nat_gateway ? var.azs : {}

  destination_cidr_block = "0.0.0.0/0"
  # single_nat_gatewayがtrueのときa向けのルートが2つ, falseの場合はa,cそれぞれ1つずつ作成される
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? keys(var.azs)[0] : each.key].id
  route_table_id         = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = var.azs

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}