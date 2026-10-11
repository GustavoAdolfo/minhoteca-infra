variable "application_tags" {
  type = map(string)
}

variable "kms_key_arn" {
  type        = string
  description = "ARN da chave KMS Minhoteca usada para criptografar a tabela"
}