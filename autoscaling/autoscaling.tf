resource "aws_autoscaling_group" "test" {
  name                = "test"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 3
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.test.arn]

  launch_template {
    id = aws_launch_template.test.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
