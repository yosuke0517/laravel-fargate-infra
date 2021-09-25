resource "aws_iam_user" "github" {
  name = "${local.name_prefix}-${local.service_name}-github"

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-github"
  }
}

resource "aws_iam_role" "deployer" {
  name = "${local.name_prefix}-${local.service_name}-deployer"

  assume_role_policy = jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "sts:AssumeRole", # IAM ユーザーからIAM ロールにAssume Role する
          "sts:TagSession" # セッションタグの受け渡しを許可するよう設定
        ],
        Principal : {
          "AWS" : aws_iam_user.github.arn
        }
      }
    ]
  }
  )

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-deployer"
  }
}

# ecr push 用のiam policy
data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "role_deployer_policy_ecr_power_user" {
  role       = aws_iam_role.deployer.name
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
}