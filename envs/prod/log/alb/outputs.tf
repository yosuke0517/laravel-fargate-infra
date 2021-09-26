# output 別のディレクトリから参照するためにモジュール外へ公開する
output "s3_bucket_this_id" {
  value = aws_s3_bucket.this.id
}