resource "aws_route53_record" "root_a" {
  zone_id = var.root_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root_aaaa" {
  zone_id = var.root_zone_id
  name    = var.domain_name
  type    = "AAAA"
  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.root_zone_id # zona principal do domínio
  name    = "www"
  type    = "A"
  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}
