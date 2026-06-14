resource "aws_cloudfront_origin_access_control" "cf_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "CloudFront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "resources_path_rewrite" {
  name    = var.arquivos_path_rewrite
  runtime = "cloudfront-js-2.0"
  comment = "Remove /arquivos do path antes de encaminhar ao bucket S3"
  publish = true
  code    = <<-EOT
function handler(event) {
  var request = event.request;

  if (request.uri === '/arquivos') {
    request.uri = '/';
    return request;
  }

  if (request.uri.indexOf('/arquivos/') === 0) {
    request.uri = request.uri.substring('/arquivos'.length);
  }

  return request;
}
EOT
}

resource "aws_cloudfront_function" "spa_route_rewrite" {
  name    = var.spa_route_rewrite
  runtime = "cloudfront-js-2.0"
  comment = "Reescreve apenas rotas SPA para /index.html sem mascarar erro de asset"
  publish = true
  code    = <<-EOT
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri === '/' || uri === '') {
    request.uri = '/index.html';
    return request;
  }

  if (uri.indexOf('/arquivos') === 0) {
    return request;
  }

  var lastSlashIndex = uri.lastIndexOf('/');
  var lastSegment = lastSlashIndex >= 0 ? uri.substring(lastSlashIndex + 1) : uri;
  var hasExtension = lastSegment.indexOf('.') !== -1;

  if (!hasExtension) {
    request.uri = '/index.html';
  }

  return request;
}
EOT
}


resource "aws_cloudfront_cache_policy" "arquivos_cache_policy" {
  name    = var.arquivos_cache_policy_name
  comment = "Cache policy for static arquivos with long TTL"

  # O navegador manterá o cache por 1 dia por padrão.
  default_ttl = var.arquivos_cache_policy_default_ttl

  # O cache na CDN e no navegador pode durar até 1 ano.
  max_ttl = var.arquivos_cache_policy_max_ttl

  # O cache deve ser revalidado com a origem no mínimo por X segundos
  min_ttl = var.arquivos_cache_policy_min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["www.${var.domain_name}", var.domain_name]
  is_ipv6_enabled     = true
  comment             = var.bucket_frontend_name
  http_version        = "http2"
  wait_for_deployment = true

  # Primary origin with default cache behavior
  origin {
    domain_name              = var.bucket_frontend_regional_domain_name
    origin_id                = var.bucket_frontend_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_s3_oac.id
  }

  # Secondary origin with path-pattern based cache behavior
  origin {
    domain_name              = var.bucket_arquivos_domain_name
    origin_id                = var.bucket_arquivos_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_s3_oac.id
  }

  default_cache_behavior {
    target_origin_id       = var.bucket_frontend_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa_route_rewrite.arn
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/resources/*"
    target_origin_id       = var.bucket_arquivos_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.arquivos_cache_policy.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.resources_path_rewrite.arn
    }
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # restriction_type = "whitelist"
      # locations        = ["BR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_log.bucket_domain_name
    prefix          = "log"
  }

  # web_acl_id = data.aws_wafv2_web_acl.waf_cloudfront.arn

  tags = merge(var.application_tags, { Contexto = "Frontend" })

  depends_on = [
    aws_s3_bucket.cdn_log,
    aws_s3_bucket_ownership_controls.cdn_log_ownership,
    aws_s3_bucket_acl.cdn_log
  ]
}

resource "aws_cloudfront_response_headers_policy" "headers_policy" {
  name = "minhoteca-headers-policy"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["ALL"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.frontend.hosted_zone_id
}
