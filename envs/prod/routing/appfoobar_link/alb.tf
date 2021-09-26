resource "aws_lb" "this" {
  # terraform apply の引数でbool指定できる（falseの場合は作成されない）
  count = var.enable_alb ? 1 : 0

  name = "${local.name_prefix}-yosukedev-link"

  # trueにすると内部ロードバランサーになる
  # falseにするとインターネット向けロードバランサーになる
  internal           = false
  load_balancer_type = "application"

  # logの保存設定
  access_logs {
    # terraform_remote_stateを使用してoutputsを取得
    bucket  = data.terraform_remote_state.log_alb.outputs.s3_bucket_this_id
    enabled = true
    prefix  = "yosukedev-link"
  }

  security_groups = [
    data.terraform_remote_state.network_main.outputs.security_group_web_id,
    data.terraform_remote_state.network_main.outputs.security_group_vpc_id
  ]

  # for s in 繰り返し対象listでidを繰り返し詰めている
  subnets = [
  for s in data.terraform_remote_state.network_main.outputs.subnet_public : s.id
  ]

  tags = {
    Name = "${local.name_prefix}-yosukedev-link"
  }
}

# リスナーの作成
resource "aws_lb_listener" "https" {
  count = var.enable_alb ? 1 : 0

  # httpsの場合はcertificate_arnが必要
  certificate_arn   = aws_acm_certificate.root.arn
  # ロードバランサのarn
  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  # こちらもhttpsの場合は必要
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.foobar.arn
  }
}

# httpリクエストからhttpsに流すためのリスナー
resource "aws_lb_listener" "redirect_http_to_https" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "foobar" {
  name = "${local.name_prefix}-foobar"

  deregistration_delay = 60
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.terraform_remote_state.network_main.outputs.vpc_this_id
  # ヘルスチェックの設定
  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-foobar"
  }
}