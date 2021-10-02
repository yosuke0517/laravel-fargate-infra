terraform {
  backend "s3" {
    bucket = "laravel-fargate-app-test-tfstate"
    key    = "example/prod/log/db_foobar_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}