terraform {
  backend "s3" {
    bucket = "laravel-fargate-app-test-tfstate"
    key    = "example/prod/routing/foobar_internal_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}