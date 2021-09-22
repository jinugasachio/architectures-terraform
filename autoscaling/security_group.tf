resource "aws_security_group" "sg_for_lb" {
  name   = "for-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sg_rule_for_lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_lb.id
}

resource "aws_security_group" "sg_for_ec2" {
  name   = "for-ec2"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sg_rule_for_ec2_1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.sg_for_ec2.id
}

resource "aws_security_group_rule" "sg_rule_for_ec2_2" {
  type              = "egress"
  from_port         = 0
  to_port           = 65536
  protocol          = "-1" # TCP/UDP両方の指定
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_for_ec2.id
}

