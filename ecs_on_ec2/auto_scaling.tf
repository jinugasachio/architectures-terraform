resource "aws_autoscaling_group" "for_ecs" {
  name                = "test"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.for_ecs.arn]

  launch_template {
    id      = aws_launch_template.for_container_instance.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}