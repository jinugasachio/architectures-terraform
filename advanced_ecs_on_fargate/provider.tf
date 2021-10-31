terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }

  backend "s3" {
    bucket = "architectures-terraform"
    key    = "architectures-terraform/advanced_ecs_on_fargate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}