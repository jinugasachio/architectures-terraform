terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
    eksctl = {
      source  = "mumoshu/eksctl"
      version = "0.16.2"
    }
  }

  backend "s3" {
    bucket = "architectures-terraform"
    key    = "architectures-terraform/eks_on_ec2"
    region = "ap-northeast-1"
  }
}