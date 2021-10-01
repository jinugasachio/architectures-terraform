resource "aws_ecs_cluster" "example" {
  name = "example"

  # CloudWatch Container Insightsの有効化
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}