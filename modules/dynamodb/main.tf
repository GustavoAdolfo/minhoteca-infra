resource "aws_dynamodb_table" "lista_classificacao" {
  name         = "minhoteca-lista-classificacao"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "tipo"
  range_key    = "idUsuario"

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  attribute {
    name = "tipo"
    type = "S"
  }

  attribute {
    name = "idUsuario"
    type = "S"
  }

  tags = merge(
    var.application_tags,
    {
      Name = "minhoteca-lista-classificacao"
    },
    {
      Contexto = "Administração"
    }
  )
}
