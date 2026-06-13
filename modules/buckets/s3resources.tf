resource "aws_s3_bucket" "resources" {
  bucket = var.bucket_resources_name
  tags   = merge(var.application_tags, { Contexto = "Frontend" })
}

resource "aws_s3_bucket_public_access_block" "resources" {
  bucket                  = aws_s3_bucket.resources.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "resources" {
  bucket = aws_s3_bucket.resources.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.resources]
}

resource "aws_s3_bucket_versioning" "resources" {
  bucket = aws_s3_bucket.resources.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "resources_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.resources]
  bucket     = aws_s3_bucket.resources.bucket
  acl        = "private"
}


resource "aws_s3_bucket_cors_configuration" "cors_resources" {
  bucket = aws_s3_bucket.resources.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    expose_headers  = []
    max_age_seconds = 60 * 60
    allowed_origins = var.bucket_resources_allowed_origins
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.bucket_resources_allowed_origins
    allowed_headers = ["*"]
    max_age_seconds = 60 * 60
    expose_headers  = []
  }
}

data "aws_iam_policy_document" "resource" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.resources.arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cf_resources.arn, aws_cloudfront_distribution.cf_dist.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "resource" {
  bucket = var.bucket_resources_name
  policy = data.aws_iam_policy_document.resource.json
}

output "bucket_resources_name" {
  value = aws_s3_bucket.resources.id
}
output "bucket_resources_arn" {
  value = aws_s3_bucket.resources.arn
}
output "bucket_resources_domain_name" {
  value = aws_s3_bucket.resources.bucket_domain_name
}

output "bucket_resources_regional_domain_name" {
  value = aws_s3_bucket.resources.bucket_regional_domain_name
}

