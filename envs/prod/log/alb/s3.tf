resource "aws_s3_bucket" "this" {
  bucket = "laravel-fargate-app-test-${local.name_prefix}-alb-log"
  # 暗号化の設定（以下だとS3が管理するキーにより暗号化が行われる）
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "laravel-fargate-app-test-${local.name_prefix}-alb-log"
  }

  lifecycle_rule {
    enabled = true
    # 何日保持するか
    expiration {
      days = "90"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          # dataにて取得しハードコードを避けている
          "AWS" : "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
        },
        Action : "s3:PutObject",
        Resource : "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
      },
      {
        Effect : "Allow",
        Principal : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        Action : "s3:PutObject",
        Resource : "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
        Condition : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        Effect : "Allow",
        Principal : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        Action : "s3:GetBucketAcl",
        Resource : "arn:aws:s3:::${aws_s3_bucket.this.id}"
      }
    ]
  }
  )
}