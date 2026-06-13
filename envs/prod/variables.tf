variable "domain_name" {
  type        = string
  description = "O nome do domínio a ser utilizado para os registros DNS"
}

variable "dnssec_name" {
  type        = string
  description = "O nome do domínio a ser utilizado para o DNSSEC"
}

variable "enable_dnssec" {
  type        = bool
  description = "Habilitar ou desabilitar o DNSSEC para o domínio"
  default     = false
}

variable "kms_log_description" {
  type        = string
  description = "Descrição para a chave KMS utilizada para criptografar os logs do Route 53"
}
variable "kms_verify_alias_name" {
  type        = string
  description = "Nome do alias para a chave KMS utilizada para verificação do DNSSEC"
}
variable "kms_verify_description" {
  type        = string
  description = "Descrição para a chave KMS utilizada para verificação do DNSSEC"
}

variable "kms_log_alias_name" {
  type        = string
  description = "Nome do alias para a chave KMS utilizada para criptografar os logs do Route 53"
}

variable "bucket_frontend_name" {
  type        = string
  description = "Name of the S3 bucket to store the frontend application"
}
variable "bucket_frontend_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS configuration of the frontend bucket"
}
variable "bucket_resources_name" {
  type        = string
  description = "Name of the S3 bucket to store the resources for the frontend application"
}
variable "bucket_resources_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS configuration of the resources bucket"
}

# variable "default_name" {
#   description = "Nome base para os recursos do projeto Minhoteca"
#   type        = string
#   default     = "minhoteca"
# }
# # variable "authors_file" { type = string }
# # variable "books_file" { type = string }
# # variable "countries_file" { type = string }
# # variable "default_kms_alias" { type = string }
# variable "domain_log_policy" { type = string }
# # variable "dynamodb_hash_authors" { type = string }
# # variable "dynamodb_hash_books" { type = string }
# # variable "dynamodb_hash_pages" { type = string } 
# # variable "dynamodb_hash_statistics" { type = string }
# # variable "enable_token_mfa" { type = bool }
# # variable "lambda_borrow_service_invoke_arn" { type = string }
# variable "log_route53_group_name" { type = string }
# variable "log_zone_retention_in_days" { type = number }
# # variable "publishers_file" { type = string }
# variable "access_token_validity" { type = number }
# variable "api_log_retention_in_days" { type = number }
# variable "api_minimum_compression" { type = string }
# variable "api_quota_settings_limit" { type = string }
# variable "api_quota_settings_offset" { type = string }
# variable "api_quota_settings_period" { type = string }
# variable "api_stage_default_variables" { type = map(any) }
# variable "api_throttle_settings_burst" { type = string }
# variable "api_throttle_settings_rate" { type = string }
# variable "cache_cluster_enabled" { type = bool }
# variable "cache_cluster_size" { type = number }
# variable "callback_urls" { type = list(string) }
# variable "css_file_path" { type = string }
# variable "default_email" { type = string }
# variable "default_redirect" { type = string }
# variable "deletion_protection" { type = string }
# variable "email_about_link" { type = string }
# variable "email_privacy_policy_link" { type = string }
# variable "email_use_term" { type = string }
# variable "enable_api_xray" { type = bool }
# variable "id_token_validity" { type = number }
# variable "logo_content_type" { type = string }
# variable "logo_file_path" { type = string }
# variable "logo_img" { type = string }
# variable "logout_urls" { type = list(string) }
# variable "metrics_enabled" { type = bool }
# variable "mfa_configuration" { type = string }
# variable "profile_picture_path" { type = string }
# variable "refresh_token_validity" { type = number }
# variable "reply_to_email_address" { type = string }
# variable "ses_verified_email_account" { type = string }
# variable "template_email_confirmation" { type = string }
# variable "template_email_login" { type = string }
# variable "template_email_signup" { type = string }
# variable "unit_access_token" { type = string }
# variable "unit_id_token" { type = string }
# variable "unit_refresh_token" { type = string }
# variable "use_terms_document_path" { type = string }

# variable "lambda_admin_dynamodb_repository" {
#   type    = bool
#   default = false
# }

# variable "lambda_admin_livro_table_name" {
#   type    = string
#   default = "Livros"
# }

# variable "lambda_admin_autor_table_name" {
#   type    = string
#   default = "Autores"
# }

# variable "lambda_admin_editora_table_name" {
#   type    = string
#   default = "Editoras"
# }

# variable "lambda_admin_pais_table_name" {
#   type    = string
#   default = "Paises"
# }

# variable "lambda_admin_fotos_autores_s3_path" {
#   type    = string
#   default = "autores/fotos/"
# }

# variable "lambda_admin_fotos_livros_s3_path" {
#   type    = string
#   default = "livros/fotos/"
# }

# variable "lambda_admin_s3_prefixo_imagem_dispositivos" {
#   type    = string
#   default = "dispositivos"
# }

# variable "lambda_admin_s3_prefixo_imagem_padrao" {
#   type    = string
#   default = "padrao"
# }

# variable "lambda_environment" {
#   type    = string
#   default = "debug"
# }

# variable "lambda_mongodb_username" {
#   type      = string
#   default   = ""
#   sensitive = true
# }

# variable "lambda_mongodb_password" {
#   type      = string
#   default   = ""
#   sensitive = true
# }

# variable "lambda_mongodb_database" {
#   type    = string
#   default = ""
# }

# variable "lambda_mongodb_cluster" {
#   type    = string
#   default = ""
# }

# variable "lambda_mongodb_appname" {
#   type    = string
#   default = "minhoteca-admin"
# }

# # variable "library_service_data_expiration_days" {
# #   type    = number
# #   default = 1
# # }

