data "aws_ecs_service" "this" {
  cluster_arn  = "${local.name_prefix}-${local.service_name}"
  service_name = "${local.name_prefix}-${local.service_name}"
}

data "aws_s3_bucket" "env_file" {
  bucket = "laravel-fargate-app-test-${local.name_prefix}-${local.service_name}-env-file"
}