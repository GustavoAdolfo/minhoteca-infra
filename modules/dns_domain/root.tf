resource "aws_route53_zone" "root" {
  # checkov:skip=CKV2_AWS_39
  name    = var.domain_name
  comment = "Hosted zone for ${var.domain_name}"
  tags    = merge(var.application_tags, { Contexto = "CDN" })
}

resource "aws_route53_key_signing_key" "root" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id             = aws_route53_zone.root.id
  key_management_service_arn = var.kms_dns_verify_arn
  name                       = var.dnssec_name
  status                     = "ACTIVE"
}

resource "aws_route53_hosted_zone_dnssec" "root" {
  count = var.enable_dnssec ? 1 : 0

  depends_on     = [aws_route53_key_signing_key.root]
  hosted_zone_id = aws_route53_key_signing_key.root[0].hosted_zone_id
}

output "zone_id" {
  value = aws_route53_zone.root.zone_id
}
output "zone_name_servers" {
  value = aws_route53_zone.root.name_servers
}
output "zone_name" {
  value = aws_route53_zone.root.name
}
