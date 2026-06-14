resource "aws_s3_bucket" "arquivos" {
  bucket = var.bucket_arquivos_name
  tags   = merge(var.application_tags, { Contexto = "Frontend" })
}

resource "aws_s3_bucket_public_access_block" "arquivos" {
  bucket                  = aws_s3_bucket.arquivos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "arquivos" {
  bucket = aws_s3_bucket.arquivos.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.arquivos]
}

resource "aws_s3_bucket_versioning" "arquivos" {
  bucket = aws_s3_bucket.arquivos.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "arquivos_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.arquivos]
  bucket     = aws_s3_bucket.arquivos.bucket
  acl        = "private"
}


resource "aws_s3_bucket_cors_configuration" "cors_arquivos" {
  bucket = aws_s3_bucket.arquivos.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    expose_headers  = []
    max_age_seconds = 60 * 60
    allowed_origins = var.bucket_arquivos_allowed_origins
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.bucket_arquivos_allowed_origins
    allowed_headers = ["*"]
    max_age_seconds = 60 * 60
    expose_headers  = []
  }
}

data "aws_iam_policy_document" "s3_arquivos_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.arquivos.arn}/*"
    ]
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
}

resource "aws_s3_bucket_policy" "s3_arquivos_policy" {
  bucket = var.bucket_arquivos_name
  policy = data.aws_iam_policy_document.s3_arquivos_policy_document.json
}

output "bucket_arquivos_name" {
  value = aws_s3_bucket.arquivos.id
}
output "bucket_arquivos_arn" {
  value = aws_s3_bucket.arquivos.arn
}
output "bucket_arquivos_domain_name" {
  value = aws_s3_bucket.arquivos.bucket_domain_name
}

output "bucket_arquivos_regional_domain_name" {
  value = aws_s3_bucket.arquivos.bucket_regional_domain_name
}

