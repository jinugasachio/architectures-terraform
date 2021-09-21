data "aws_ami" "test" {
  name_regex  = "^amzn2-ami-hvm-2.0.2021*"
  most_recent = true
  owners      = ["amazon"]
}
resource "aws_launch_template" "test" {
  name                   = "for-autoscaling"
  image_id               = data.aws_ami.test.image_id
  instance_type          = "t2.micro"
  key_name               = "jinugasachioforaws"
  vpc_security_group_ids = [aws_security_group.for_ec2.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.test.arn
  }

  user_data = filebase64("./example.sh")
}

resource "aws_iam_instance_profile" "test" {
  name = "test"
  role = aws_iam_role.test.name
}