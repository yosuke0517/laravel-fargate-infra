resource "aws_subnet" "public" {
  # variablesで定義しているmapをfor文で回す。a,cと回るので2つのpublicサブネットができる
  for_each = var.azs
  # data.aws_region.current.nameにはap-northeast-1が入る
  availability_zone       = "${data.aws_region.current.name}${each.key}" # ap-northeast-1a, 1c
  cidr_block              = each.value.public_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.azs

  availability_zone       = "${data.aws_region.current.name}${each.key}"
  cidr_block              = each.value.private_cidr
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}