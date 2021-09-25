# リソースを1 つだけ作成するような場合は、this と付ける
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    # VPCから取得（同じ名前）
    Name = aws_vpc.this.tags.Name
  }
}