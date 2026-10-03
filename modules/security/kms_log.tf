data "aws_iam_policy_document" "kms_policy_encrypt" {
  statement {
    sid    = "MinhotecaKMSPolicyEncryptUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    resources = ["*"]
    actions   = ["kms:*"]
  }
  statement {
    sid    = "MinhotecaKMSPolicyEncryptLogsServicePermissions"
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
      values   = ["arn:aws:logs:${var.region}:${var.account_id}:log-group:*"]
    }
  }
  statement {
    sid    = "MinhotecaKMSPolicyEncryptSSMServicePermissions"
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
    sid    = "MinhotecaKMSPolicyEncryptRootUserPermissions"
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

  statement {
    sid       = "MinhotecaKMSPolicyEncrypterServicesPermissions"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "sqs.${var.account_id}.amazonaws.com",
        "sns.${var.account_id}.amazonaws.com",
        "s3.${var.account_id}.amazonaws.com",
        "dynamodb.${var.account_id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.account_id}"]
    }
  }

  statement {
    sid       = "MinhotecaKMSPolicyEncryptSecretsManagerPermissions"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.${var.account_id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.account_id}"]
    }
  }

  statement {
    sid       = "MinhotecaKMSPolicyEncryptCloudFrontPermissions"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "cloudfront.${var.account_id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.account_id}"]
    }
  }

  statement {
    sid       = "MinhotecaKMSPolicyEncryptLambdaAndAPIGatewayPermissions"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "lambda.${var.account_id}.amazonaws.com",
        "apigateway.${var.account_id}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.account_id}"]
    }
  }
}

resource "aws_kms_key" "minhoteca_encrypt" {
  description                        = var.kms_log_description
  key_usage                          = "ENCRYPT_DECRYPT"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  multi_region                       = false
  is_enabled                         = true
  bypass_policy_lockout_safety_check = false
  rotation_period_in_days            = 365
  deletion_window_in_days            = 7
  enable_key_rotation                = true
  tags                               = merge(var.application_tags, { Contexto = "Seguranca" })
}

resource "aws_kms_alias" "minhoteca_encrypt" {
  target_key_id = aws_kms_key.minhoteca_encrypt.key_id
  name          = var.kms_log_alias_name
}

resource "aws_kms_key_policy" "minhoteca_encrypt" {
  key_id = aws_kms_key.minhoteca_encrypt.id
  policy = data.aws_iam_policy_document.kms_policy_encrypt.json
}

output "minhoteca_encrypt_arn" {
  value = aws_kms_key.minhoteca_encrypt.arn
}
output "minhoteca_encrypt_key_id" {
  value = aws_kms_key.minhoteca_encrypt.key_id
}
output "minhoteca_encrypt_alias" {
  value = aws_kms_alias.minhoteca_encrypt.name
}
output "minhoteca_encrypt_alias_arn" {
  value = aws_kms_alias.minhoteca_encrypt.arn
}
