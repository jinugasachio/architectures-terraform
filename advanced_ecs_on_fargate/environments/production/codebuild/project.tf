resource "aws_codebuild_project" "continuous_apply" {
  name         = "continuous-apply"
  service_role = module.continuous_apply_codebuild_role.iam_role_arn

  source {
    type     = "GITHUB" # ビルドするコードがあるリポジトリの種類
    location = "https://github.com/jinugasachio/architectures-terraform/tree/main/advanced_ecs_on_fargate" # GITHUB or S3の場合は指定する
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "hashicorp/terraform:0.12.5"
    privileged_mode = false
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws codebuild import-source-credentials \
        --server-type GITHUB \
        --auth-type PERSONAL_ACCESS_TOKEN \
        --token $GITHUB_TOKEN
    EOT

    environment = {
      GITHUB_TOKEN = data.aws_ssm_parameter.github_token.value
    }
  }
}

data "aws_ssm_parameter" "github_token" {
  name = "/yukio-ugajin-test/continuous_apply/github_token"
}
