resource "aws_iam_role" "for_ecs_instance" {
  name               = "test"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

/**********************************
* コンテナインスタンスにマストで必要なロール
**********************************/

resource "aws_iam_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  name       = "test"
  roles      = [aws_iam_role.for_ecs_instance.name]
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  # 一応中身を載せておく
  # {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #         {
  #             "Effect": "Allow",
  #             "Action": [
  #                 "ec2:DescribeTags",
  #                 "ecs:CreateCluster",
  #                 "ecs:DeregisterContainerInstance",
  #                 "ecs:DiscoverPollEndpoint",
  #                 "ecs:Poll",
  #                 "ecs:RegisterContainerInstance",
  #                 "ecs:StartTelemetrySession",
  #                 "ecs:UpdateContainerInstancesState",
  #                 "ecs:Submit*",
  #                 "ecr:GetAuthorizationToken",
  #                 "ecr:BatchCheckLayerAvailability",
  #                 "ecr:GetDownloadUrlForLayer",
  #                 "ecr:BatchGetImage",
  #                 "logs:CreateLogStream",
  #                 "logs:PutLogEvents"
  #             ],
  #             "Resource": "*"
  #         }
  #     ]
  # }
}

/*****************************************************************
* セッションマネージャーからprivateなインスタンスにアクセスできるようにする
******************************************************************/

resource "aws_iam_policy_attachment" "AmazonSSMManagedInstanceCore" {
  name       = "test"
  roles      = [aws_iam_role.for_ecs_instance.name]
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}