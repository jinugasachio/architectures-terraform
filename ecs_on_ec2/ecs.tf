resource "aws_ecs_cluster" "test" {
  name = "test"

  # CloudWatch Container Insightsの有効化
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "test" {
  family = "web"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      cpu       = 10
      memory    = 100
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 0 # 動的ポートマッピング。ホスト先のインスタンスのportをエフェメラルポートの範囲 (49153-65535 と 32768–61000)でランダム？に解放する
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "test" {
  name                              = "test"
  cluster                           = aws_ecs_cluster.test.id
  task_definition                   = aws_ecs_task_definition.test.arn
  desired_count                     = 2
  launch_type                       = "EC2"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.for_ecs.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
