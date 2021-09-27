# SSL証明書の作成
resource "aws_acm_certificate" "example" {
  domain_name               = aws_route53_record.example.name
  subject_alternative_names = []
  validation_method         = "DNS" # 自動更新したい場合はDNSを指定するらしい

  lifecycle {
    create_before_destroy = true # 新しい証明書を作ってから、古い証明書と差し替えるという挙動にしたいので。
  }
}

# 検証用DNSレコード
resource "aws_route53_record" "example_certificate" {
  name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.example.zone_id
  ttl     = 60
}

# 検証の待機。apply時にSSL証明書の検証が完了するまで待ってくれる。何かリソースが作られるわけではない。
resource "aws_acm_certificate_validation" "example" {
  certificate_arn = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}
