resource "aws_kms_key" "minhoteca_verify" {
  description              = var.kms_verify_description
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  enable_key_rotation      = false
  tags                     = merge(var.application_tags, { Contexto = "Security" })
}

data "aws_iam_policy_document" "kms_policy_verify" {
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "MinhotecaAllowRoute53DNSSECService"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    actions = [
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:Sign",
      "kms:Verify"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:route53:::hostedzone/*"]
    }
  }
  statement {
    actions = ["kms:CreateGrant"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dnssec-route53.amazonaws.com"]
    }
    sid       = "MinhotecaAllowRoute53DNSSECServiceToCreateGrant"
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  statement {
    actions = ["kms:*"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    resources = ["*"]
    sid       = "MinhotecaKMSEnableIAMUserPermissions"
  }
}

resource "aws_kms_key_policy" "minhoteca_verify" {
  key_id = aws_kms_key.minhoteca_verify.id
  policy = data.aws_iam_policy_document.kms_policy_verify.json
}

resource "aws_kms_alias" "minhoteca_verify" {
  target_key_id = aws_kms_key.minhoteca_verify.key_id
  name          = var.kms_verify_alias_name
}

output "kms_minhoteca_verify_arn" {
  value = aws_kms_key.minhoteca_verify.arn
}
