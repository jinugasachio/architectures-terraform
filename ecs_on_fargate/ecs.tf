resource "aws_ecs_cluster" "example" {
  name = "example"

  # CloudWatch Container Insightsの有効化
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  cpu                      = "256"    # FARGATEの場合はrequired
  memory                   = "512"    # FARGATEの場合はrequired
  network_mode             = "awsvpc" # FARGATEの場合はrequired かつ aws_vpcを指定する。https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/AWS_Fargate.html 
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "example" {
  name                              = "example"
  cluster                           = aws_ecs_cluster.example.arn
  task_definition                   = aws_ecs_task_definition.example.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0" # デフォルトはLATESTだが、名前に反して最新ではない場合がある。ので明示するのがベストプラクティス。https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/platform_versions.html 
  health_check_grace_period_seconds = 60

  # aws_vpcのネットワークモードの際は必須項目。むしろ他のモードの時は設定できない。
  network_configuration {
    assign_public_ip = false # FARGATEタイプの場合のみ設定可能。今回はprivateにしたいのでfalse。
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example"
    container_port   = 80
  }

  # FARGATEの場合デプロイのたびにタスク定義が更新されplan時に差分がでる。
  # よってterraformではタスク定義の変更を無視すべき。
  lifecycle {
    ignore_changes = [task_definition]
  }
}

module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = [aws_vpc.example.cidr_block]
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-task.amazonaws.com" # ECSでこのroleを使用することを宣言
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

