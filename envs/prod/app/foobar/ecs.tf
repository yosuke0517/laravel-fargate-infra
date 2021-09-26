resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"
  # FARGATE_SPOT: 中断の可能性はあるが値段が安い。個人開発ではこれでいいかも
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

# タスク定義
resource "aws_ecs_task_definition" "this" {
  # タスク定義の名前
  family = "${local.name_prefix}-${local.service_name}"

  task_role_arn = aws_iam_role.ecs_task.arn

  network_mode = "awsvpc"

  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  memory = "512"
  cpu    = "256"

  # タスクで動かす各コンテナの設定
  container_definitions = jsonencode(
  [
    {
      name  = "nginx"
      image = "${module.nginx.ecr_repository_this_repository_url}:latest"

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = []
      secrets     = []

      dependsOn = [
        {
          containerName = "php"
          condition     = "START"
        }
      ]

      mountPoints = [
        {
          containerPath = "/var/run/php-fpm"
          sourceVolume  = "php-fpm-socket"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/nginx"
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name  = "php"
      image = "${module.php.ecr_repository_this_repository_url}:latest"

      portMappings = []

      environment = []

      # コンテナに環境変数を渡す
      secrets = [
        {
          name      = "APP_KEY"
          # セキュリティ的にはコンソールで登録したものを参照するのが正
          valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/APP_KEY"
        }
      ]

      mountPoints = [
        {
          containerPath = "/var/run/php-fpm"
          sourceVolume  = "php-fpm-socket"
        }
      ]

      logConfiguration = {
        # cloudWatch Logsにコンテナのログを出力する設定
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/php"
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]
  )

  volume {
    name = "php-fpm-socket"
  }

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

# ECSサービスの作成
resource "aws_ecs_service" "this" {
  name = "${local.name_prefix}-${local.service_name}"

  cluster = aws_ecs_cluster.this.arn

  capacity_provider_strategy {
    # 運用フェーズに入ったらFARGATEも選択肢に入れる（devならFARGATE_SPOTで十分かも）
    capacity_provider = "FARGATE_SPOT"
    base              = 0 # capacity_providerが1つのときはbaseに入る値は意味を持たない（2つ以上設定するときは要確認）
    weight            = 1 # capacity_providerが1つのときはbaseに入る値は意味を持たない（2つ以上設定するときは要確認）
  }

  platform_version = "1.4.0"

  # タスク定義を指定
  task_definition = aws_ecs_task_definition.this.arn

  desired_count                      = var.desired_count # 起動させておくタスク数
  deployment_minimum_healthy_percent = 100 # 単位: % →desired_countに対する％なので普段はタスクが1個
  deployment_maximum_percent         = 200 # ローリングアップデート時には2個になる
  # リクエストが多いサービスでは最低1個では捌き切れないので調整が必要

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = data.terraform_remote_state.routing_appfoobar_link.outputs.lb_target_group_foobar_arn
  }

  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [
      data.terraform_remote_state.network_main.outputs.security_group_vpc_id
    ]
    # for s in 繰り返し対象listでidを繰り返し詰めている
    subnets = [
    for s in data.terraform_remote_state.network_main.outputs.subnet_private : s.id
    ]
  }
  # ECS Exec を利⽤する場合はtrue にする
  enable_execute_command = true

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}