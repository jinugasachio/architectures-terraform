resource "aws_kms_key" "example" {
  description             = "CMK"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "example" {
  name          = "alias/example" # alias/~ と記述する必要がある
  target_key_id = aws_kms_key.example.key_id
}
