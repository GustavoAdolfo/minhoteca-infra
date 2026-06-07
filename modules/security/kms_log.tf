resource "aws_kms_key" "minhoteca_encrypt_cdn_log" {
  description              = var.kms_log_description
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = true
  tags                     = merge(var.application_tags, { Contexto = "Seguranca" })
}

data "aws_iam_policy_document" "kms_policy_encrypt" {
  statement {
    sid    = "MinhotecaKMSPolicyEncryptUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
    actions   = ["kms:*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${var.account_id}:log-group"]
    }
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "minhoteca_encrypt_cdn_log" {
  key_id = aws_kms_key.minhoteca_encrypt_cdn_log.id
  policy = data.aws_iam_policy_document.kms_policy_encrypt.json
}

resource "aws_kms_alias" "minhoteca_encrypt_cdn_log" {
  target_key_id = aws_kms_key.minhoteca_encrypt_cdn_log.key_id
  name          = var.kms_log_alias_name
}

output "minhoteca_encrypt_cdn_log_arn" {
  value = aws_kms_key.minhoteca_encrypt_cdn_log.arn
}
output "minhoteca_encrypt_cdn_log_key_id" {
  value = aws_kms_key.minhoteca_encrypt_cdn_log.key_id
}
output "minhoteca_encrypt_cdn_log_alias" {
  value = aws_kms_alias.minhoteca_encrypt_cdn_log.name
}
output "minhoteca_encrypt_cdn_log_alias_arn" {
  value = aws_kms_alias.minhoteca_encrypt_cdn_log.arn
}
