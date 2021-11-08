terraform {
  backend "s3" {
    bucket = "yukio-ugajin-test"
    key    = "architectures-terraform/advanced_ecs_on_fargate/production" # freeeサンドボックス環境で管理なので注意
    region = "us-west-2"
  }
}