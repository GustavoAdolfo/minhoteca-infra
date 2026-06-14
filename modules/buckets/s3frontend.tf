resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_frontend_name
  tags   = merge(var.application_tags, { Contexto = "Frontend" })
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "frontend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend]
  bucket     = aws_s3_bucket.frontend.bucket
  acl        = "private"
}


resource "aws_s3_bucket_cors_configuration" "cors_frontend" {
  bucket = aws_s3_bucket.frontend.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    expose_headers  = []
    max_age_seconds = 60 * 60
    allowed_origins = var.bucket_frontend_allowed_origins
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.bucket_frontend_allowed_origins
    allowed_headers = ["*"]
    max_age_seconds = 60 * 60
    expose_headers  = []
  }
}

data "aws_iam_policy_document" "frontend_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${var.account_id}:distribution/*"
      ]
    }
  }

  statement {
    principals {
      type        = "CanonicalUser"
      identifiers = [var.user_current_id]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutBucketPolicy",
    ]

    resources = [
      aws_s3_bucket.frontend.arn,
      "${aws_s3_bucket.frontend.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.bucket
  policy = data.aws_iam_policy_document.frontend_policy_document.json
}

output "bucket_frontend_name" {
  value = aws_s3_bucket.frontend.id
}

output "bucket_frontend_arn" {
  value = aws_s3_bucket.frontend.arn
}

output "bucket_frontend_domain_name" {
  value = aws_s3_bucket.frontend.bucket_domain_name
}

output "bucket_frontend_regional_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}
