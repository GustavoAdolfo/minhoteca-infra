
resource "aws_acm_certificate_validation" "minhoteca" {
  certificate_arn         = var.certificate_minhoteca_arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
  timeouts { create = "45m" }
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in var.acm_certificate_minhoteca_validation_options : dvo.domain_name => {
      name   = dvo.resource_record.name
      record = dvo.resource_record.value
      type   = dvo.resource_record.type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.root_zone_id
}

output "certificate_minhoteca_arn" {
  value = aws_acm_certificate_validation.minhoteca.certificate_arn
}
