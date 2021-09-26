output "security_group_web_id" {
  value = aws_security_group.web.id
}

output "security_group_vpc_id" {
  value = aws_security_group.vpc.id
}

output "subnet_public" {
  # 複数取れる
  value = aws_subnet.public
}