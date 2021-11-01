terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }

  backend "s3" {
    bucket = "yukio-ugajin-test"
    key    = "architectures-terraform/advanced_ecs_on_fargate" # freeeサンドボックス環境で管理なので注意
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}