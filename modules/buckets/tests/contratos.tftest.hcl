mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Action\":\"s3:*\",\"Resource\":\"*\",\"Principal\":\"*\"}]}"
    }
  }
}

variables {
  account_id                      = "123456789012"
  application_tags                = {}
  user_current_id                 = "test-owner"
  bucket_frontend_name            = "minhoteca-test-frontend"
  bucket_frontend_allowed_origins = ["https://example.com"]
  bucket_arquivos_name            = "minhoteca-test-arquivos"
  bucket_arquivos_allowed_origins = ["https://example.com"]
  contratos_kms_key_arn           = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}

run "contratos_versionados" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.contratos.versioning_configuration[0].status == "Enabled"
    error_message = "Contratos devem manter o versionamento habilitado."
  }

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.contratos.rule :
      rule.bucket_key_enabled &&
      alltrue([
        for encryption in rule.apply_server_side_encryption_by_default :
        encryption.sse_algorithm == "aws:kms" &&
        encryption.kms_master_key_id == var.contratos_kms_key_arn
      ])
    ])
    error_message = "Os documentos devem usar SSE-KMS com a chave Minhoteca e Bucket Keys."
  }

  assert {
    condition = (
      aws_s3_bucket_public_access_block.contratos.block_public_acls &&
      aws_s3_bucket_public_access_block.contratos.block_public_policy &&
      aws_s3_bucket_public_access_block.contratos.ignore_public_acls &&
      aws_s3_bucket_public_access_block.contratos.restrict_public_buckets &&
      aws_s3_bucket_ownership_controls.contratos.rule[0].object_ownership == "BucketOwnerEnforced"
    )
    error_message = "O bucket deve ser privado e nao aceitar ACLs."
  }

  assert {
    condition = (
      length(data.aws_iam_policy_document.contratos.statement) == 5 &&
      alltrue([
        for statement in data.aws_iam_policy_document.contratos.statement :
        statement.effect == "Deny"
      ])
    )
    error_message = "A policy deve restringir transporte e criptografia sem conceder acesso generico."
  }
}
