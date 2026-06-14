resource "aws_s3_bucket" "cdn_log" {
  bucket = var.bucket_cdn_log
}

resource "aws_s3_bucket_ownership_controls" "cdn_log_ownership" {
  bucket = aws_s3_bucket.cdn_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "log_versioning" {
  bucket = aws_s3_bucket.cdn_log.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "cdn_log" {
  depends_on = [aws_s3_bucket_ownership_controls.cdn_log_ownership]
  bucket     = aws_s3_bucket.cdn_log.bucket

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_cloudfront_log_delivery_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = var.user_current_id
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_log" {
  bucket = aws_s3_bucket.cdn_log.id
  policy = data.aws_iam_policy_document.cdn_log.json
}

data "aws_iam_policy_document" "cdn_log" {
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cdn_log.arn}/*"
    ]
    principals {
      type        = "CanonicalUser"
      identifiers = [data.aws_cloudfront_log_delivery_canonical_user_id.current.id]
    }
  }
  statement {
    principals {
      type        = "CanonicalUser"
      identifiers = [var.user_current_id]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.cdn_log.arn}/*"
    ]
  }
  statement {
    principals {
      type        = "CanonicalUser"
      identifiers = [var.user_current_id]
    }
    actions = [
      "s3:ListBucket",
      "s3:PutBucketPolicy"
    ]
    resources = [
      aws_s3_bucket.cdn_log.arn
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_log" {
  bucket                  = aws_s3_bucket.cdn_log.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.cdn_log.id
  rule {
    id = "log"

    filter {}

    expiration {
      days = 180
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.cdn_log.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.cdn_log_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
