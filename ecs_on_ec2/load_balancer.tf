resource "aws_lb" "for_ecs" {
  name               = "test"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_listener" "ugajin_lb_listener" {
  load_balancer_arn = aws_lb.for_ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_ecs.arn
  }
}

resource "aws_lb_target_group" "for_ecs" {
  name     = "test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    interval = 10
    timeout  = 20
    port     = "traffic-port"
  }
}
