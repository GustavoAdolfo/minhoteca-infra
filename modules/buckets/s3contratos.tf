resource "aws_s3_bucket" "contratos" {
  bucket = "minhoteca-contratos"
  tags   = merge(var.application_tags, { Contexto = "Administração" })
}

resource "aws_s3_bucket_public_access_block" "contratos" {
  bucket                  = aws_s3_bucket.contratos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "contratos" {
  bucket = aws_s3_bucket.contratos.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
  depends_on = [aws_s3_bucket_public_access_block.contratos]
}

resource "aws_s3_bucket_versioning" "contratos" {
  bucket = aws_s3_bucket.contratos.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "contratos" {
  bucket = aws_s3_bucket.contratos.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.contratos_kms_key_arn
    }
    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "contratos" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.contratos.arn, "${aws_s3_bucket.contratos.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyExplicitNonKmsEncryption"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.contratos.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["false"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid       = "DenyExplicitDifferentKmsKey"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.contratos.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["false"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [var.contratos_kms_key_arn]
    }
  }

  statement {
    sid       = "DenyKmsEncryptionWithoutExplicitKey"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.contratos.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }
  }

  statement {
    sid       = "DenyCustomerProvidedEncryption"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.contratos.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-customer-algorithm"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "contratos" {
  bucket = aws_s3_bucket.contratos.bucket
  policy = data.aws_iam_policy_document.contratos.json
}

output "bucket_contratos_name" {
  value = aws_s3_bucket.contratos.id
}

output "bucket_contratos_arn" {
  value = aws_s3_bucket.contratos.arn
}

output "bucket_contratos_kms_key_arn" {
  value = var.contratos_kms_key_arn
}
