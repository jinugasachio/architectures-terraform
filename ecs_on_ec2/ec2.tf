data "aws_ssm_parameter" "ecs_optimized_ami_image_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "for_container_instance" {
  name                   = "test"
  image_id               = data.aws_ssm_parameter.ecs_optimized_ami_image_id.value
  instance_type          = "t2.micro"
  key_name               = "jinugasachioforaws"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.for_container_instance.arn
  }

  user_data = filebase64("./register_instance_with_cluster.sh")
}

resource "aws_iam_instance_profile" "for_container_instance" {
  name = "test"
  role = aws_iam_role.for_ecs_instance.name
}