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

# ecspresso用のs3権限付与
resource "aws_iam_role_policy" "s3" {
  name = "s3"
  role = aws_iam_role.deployer.id

  policy = jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "s3:GetObject"
        ],
        Resource : "arn:aws:s3:::laravel-fargate-app-test-tfstate/${local.system_name}/${local.env_name}/cicd/app_${local.service_name}_*.tfstate"
      },
      {
        Effect : "Allow",
        Action : [
          "s3:PutObject"
        ],
        Resource : "${data.aws_s3_bucket.env_file.arn}/*"
      },
    ]
  }
  )
}

# aws-actions/amazon-ecs-deploy-task-definition」のREADMEを参考
# See: https://github.com/aws-actions/amazon-ecs-deploy-task-definition#permissions
resource "aws_iam_role_policy" "ecs" {
  name = "ecs"
  role = aws_iam_role.deployer.id

  policy = jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "RegisterTaskDefinition",
        Effect : "Allow",
        Action : [
          "ecs:RegisterTaskDefinition"
        ],
        Resource : "*"
      },
      {
        Sid : "PassRolesInTaskDefinition",
        Effect : "Allow",
        Action : [
          "iam:PassRole"
        ],
        Resource : [
          data.aws_iam_role.ecs_task.arn,
          data.aws_iam_role.ecs_task_execution.arn,
        ]
      },
      {
        Sid : "DeployService",
        Effect : "Allow",
        Action : [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource : [
          data.aws_ecs_service.this.arn
        ]
      }
    ]
  }
  )
}