resource "aws_acm_certificate" "minhoteca" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.application_tags, { Contexto = "Security" })
}


output "acm_certificate_minhoteca_arn" {
  value = aws_acm_certificate.minhoteca.arn
}

output "acm_certificate_minhoteca_validation_options" {
  value = [
    for record in aws_acm_certificate.minhoteca.domain_validation_options : {
      domain_name = record.domain_name
      resource_record = {
        name   = record.resource_record_name
        type   = record.resource_record_type
        value  = record.resource_record_value
        ttl    = 300
        weight = 1
      }
    }
  ]
}
