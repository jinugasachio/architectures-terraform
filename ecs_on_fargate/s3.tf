resource "aws_s3_bucket" "private" {
  bucket = "ugajin-private-bucket-by-terraform"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "name" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "public" {
  bucket = "ugajin-public-bucket-by-terraform"
  acl = "public-read" # アクセスコントロールリスト。アクセスするユーザーにバケット・オブジェクトへのアクセスを許可するもの。

  cors_rule { # cors = Cross-Origin Resource Sharing
    allowed_origins = ["https://example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "ugajin-alb-log-bucket-by-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180" # 180日経過したファイルは削除
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      identifiers = ["*"] # 一時的な記述後で書き直す
    }
  }
}