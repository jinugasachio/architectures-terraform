# コンソールでいうところの信頼関係の記述部分
# 信頼関係はroleにしかない概念
data "aws_iam_policy_document" "test" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test" {
  assume_role_policy = data.aws_iam_policy_document.test.json
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 関連付けもリソースとして表現する。この部分はコンソール操作では分かりにくい部分。
resource "aws_iam_policy_attachment" "test" {
  name       = "test"
  roles      = [aws_iam_role.test.name]
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}
