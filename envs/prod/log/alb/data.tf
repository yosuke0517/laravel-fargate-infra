# 以下設定で、AWS がELB(Elastic Load Bal-ancer) の管理を⾏なっているAWS アカウントID を参照できる
# AWS の個人アカウントIDではなく東京リージョンであればアカウントID は「582318560864」と決まっている
data "aws_elb_service_account" "current" {}