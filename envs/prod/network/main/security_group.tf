# http, https通信を許可する
resource "aws_security_group" "web" {
  name   = "${aws_vpc.this.tags.Name}-web"
  vpc_id = aws_vpc.this.id
  # ingress: インバウンド通信（入ってくる通信の許可）
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # アウトバウンド: 出ていく通信の許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-web"
  }
}

# vpc内の通信を許可する
resource "aws_security_group" "vpc" {
  name   = "${aws_vpc.this.tags.Name}-vpc"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # self をtrue にすると、このセキュリティグループ⾃⾝が付けられたリソースからの通信が許可されます。
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-vpc"
  }
}