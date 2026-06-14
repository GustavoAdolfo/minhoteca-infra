variable "domain_name" {
  type        = string
  description = "Nome do domínio para o CloudFront (ex: minhoteca.com)"
}
variable "certificate_arn" {
  type        = string
  description = ""
}

variable "bucket_frontend_name" {
  type        = string
  description = "Nome do bucket S3 para frontend (arquivos estáticos)"
}
variable "bucket_frontend_regional_domain_name" {
  type        = string
  description = "Nome do bucket S3 para frontend (arquivos estáticos)"
}

variable "bucket_arquivos_name" {
  type        = string
  description = "Nome do bucket S3 para arquivos (uploads de usuários)"
}
variable "bucket_arquivos_domain_name" {
  type        = string
  description = "Nome do bucket S3 para arquivos (uploads de usuários)"
}

variable "bucket_cdn_log" {
  type        = string
  description = "Nome do bucket S3 para logs do CloudFront"
}

variable "application_tags" {
  type        = map(string)
  description = "Tags comuns para todos os recursos da aplicação, para facilitar a identificação e organização"
}

variable "cdn_log_key_id" {
  type        = string
  description = "ID da chave KMS para criptografia do bucket de logs do CloudFront"
}
variable "user_current_id" {
  type        = string
  description = "Canonical User ID do usuário atual (para configuração de ACLs e políticas de bucket)"
}

variable "arquivos_path_rewrite" {
  type        = string
  description = "Nome da função do CloudFront para reescrita de path dos arquivos estáticos"
}
variable "spa_route_rewrite" {
  type        = string
  description = "Nome da função do CloudFront para reescrita de rotas SPA"
}
variable "arquivos_cache_policy_name" {
  type        = string
  description = "Nome do cache policy para arquivos estáticos"
}
variable "arquivos_cache_policy_default_ttl" {
  type        = number
  description = "Default TTL para arquivos estáticos (em segundos)"
  default     = 86400
}
variable "arquivos_cache_policy_max_ttl" {
  type        = number
  description = "Max TTL para arquivos estáticos (em segundos)"
  default     = 31536000
}
variable "arquivos_cache_policy_min_ttl" {
  type        = number
  description = "Min TTL para arquivos estáticos (em segundos)"
  default     = 60
}
