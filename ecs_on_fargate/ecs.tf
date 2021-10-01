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
  cpu                      = "256"     # FARGATEの場合はrequired
  memory                   = "512"     # FARGATEの場合はrequired
  network_mode             = "aws_vpc" # FARGATEの場合はrequired かつ aws_vpcを指定する。https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/AWS_Fargate.html 
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
}

resource "aws_ecs_service" "example" {
  name                              = "example"
  cluster                           = aws_ecs_cluster.example.arn
  task_definition                   = aws_ecs_task_definition.example.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0" # デフォルトはLATESTだが、名前に反して最新ではない場合がある。ので明示するのがベストプラクティス。https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/platform_versions.html 
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [module.nginx_sg.security_group_id]

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
}

module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.example.id
  port        = 8080
  cidr_blocks = [aws_vpc.example.cidr_blocks]
}