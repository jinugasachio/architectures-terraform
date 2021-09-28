/**********************************
* HTTP/HTTPS用ロードバランサー
**********************************/

resource "aws_lb" "example" {
  name               = "example"
  internal           = false # VPC内部向け or インターネット向け
  load_balancer_type = "application"
  idle_timeout       = 60

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
  ]

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.alb_log.id
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id
  ]
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

resource "aws_lb_target_group" "example" {
  name                 = "example"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.example.id
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5 # 何回のヘルスチェック成功でhealthyとするか
    unhealthy_threshold = 2 # 何回のヘルスチェック失敗でunhealthyとするか
    timeout             = 5 # 5秒以上経ったらタイムアウトとする
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.example]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response" # 固定のhttpレスポンスを応答

    fixed_response {
      content_type = "text/plain"
      message_body = "これはHTTPです"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.example.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08" # デフォルト

  default_action {
    type = "fixed-response" # 固定のレスポンスを応答

    fixed_response {
      content_type = "text/plain"
      message_body = "これはHTTPSです"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

module "http_sg" {
  source      = "./security_group"
  name        = "http-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "./security_group"
  name        = "https-sg"
  vpc_id      = aws_vpc.example.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "./security_group"
  name        = "http-redirect-sg"
  vpc_id      = aws_vpc.example.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}
