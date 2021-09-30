terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }

  backend "s3" {
    bucket = "architectures-terraform"
    key    = "architectures-terraform/ecs_on_ec2"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}