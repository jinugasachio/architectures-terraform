resource "aws_security_group" "for_lb" {
  name   = "sg-for-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "for_lb_sg" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.for_lb.id
}

resource "aws_security_group" "for_ec2" {
  name   = "sg_for-ec2"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "for_ec2_sg_1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.for_ec2.id
}

resource "aws_security_group_rule" "for_ec2_sg_2" {
  type              = "egress"
  from_port         = 0
  to_port           = 65536
  protocol          = "-1" # TCP/UDP両方の指定
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.for_ec2.id
}

