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
  network_mode             = "aws_vpc" # FARGATEの場合はrequired かつ aws_vpcを指定する
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
}
