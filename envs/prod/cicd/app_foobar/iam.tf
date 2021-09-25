resource "aws_iam_user" "github" {
  name = "${local.name_prefix}-${local.service_name}-github"

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-github"
  }
}
