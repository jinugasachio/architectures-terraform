resource "aws_lb" "alb_for_autoscaling" {
  name               = "alb-for-autoscaling"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [
    aws_security_group.for_lb.id,
    aws_security_group.for_ec2.id
  ]
}

resource "aws_lb_target_group" "test" {
  name     = "target-group-for-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.alb_for_autoscaling.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}


