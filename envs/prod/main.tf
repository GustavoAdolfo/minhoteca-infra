terraform {
  required_version = "~> 1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Terraform = true
      Projeto   = "Minhoteca"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_canonical_user_id" "current" {}

module "appservice" {
  source = "../../modules/application"
}

module "security" {
  source                 = "../../modules/security"
  account_id             = data.aws_caller_identity.current.account_id
  kms_log_description    = var.kms_log_description
  kms_verify_alias_name  = var.kms_verify_alias_name
  kms_verify_description = var.kms_verify_description
  kms_log_alias_name     = var.kms_log_alias_name
  application_tags       = module.appservice.appregistry_tags
  domain_name            = var.domain_name
  region                 = data.aws_region.current.name
}

module "dns_domain" {
  source             = "../../modules/dns_domain"
  domain_name        = var.domain_name
  dnssec_name        = var.dnssec_name
  application_tags   = module.appservice.appregistry_tags
  enable_dnssec      = var.enable_dnssec
  kms_dns_verify_arn = module.security.kms_minhoteca_verify_arn
}

module "dns_certificate_validation" {
  source                                       = "../../modules/dns_certificate_validation"
  certificate_minhoteca_arn                    = module.security.acm_certificate_minhoteca_arn
  acm_certificate_minhoteca_validation_options = module.security.acm_certificate_minhoteca_validation_options
  root_zone_id                                 = module.dns_domain.zone_id
}

module "buckets" {
  source                          = "../../modules/buckets"
  bucket_frontend_name            = var.bucket_frontend_name
  bucket_arquivos_name            = var.bucket_arquivos_name
  bucket_frontend_allowed_origins = var.bucket_frontend_allowed_origins
  bucket_arquivos_allowed_origins = var.bucket_arquivos_allowed_origins
  application_tags                = module.appservice.appregistry_tags
  user_current_id                 = data.aws_canonical_user_id.current.id
  account_id                      = data.aws_caller_identity.current.account_id
}

# module "cdn" {
#   source                               = "../../modules/cdn"
#   domain_name                          = var.domain_name
#   certificate_arn                      = module.security.acm_certificate_minhoteca_arn
#   bucket_frontend_name                 = module.buckets.bucket_frontend_name
#   bucket_arquivos_name                 = module.buckets.bucket_arquivos_name
#   bucket_frontend_regional_domain_name = module.buckets.bucket_frontend_regional_domain_name
#   bucket_arquivos_domain_name          = module.buckets.bucket_arquivos_domain_name
#   bucket_cdn_log                       = var.bucket_cdn_log
#   application_tags                     = module.appservice.appregistry_tags
#   cdn_log_key_id                       = module.security.minhoteca_encrypt_cdn_log_key_id
#   user_current_id                      = data.aws_canonical_user_id.current.id
#   arquivos_path_rewrite                = var.arquivos_path_rewrite
#   spa_route_rewrite                    = var.spa_route_rewrite
#   arquivos_cache_policy_name           = var.arquivos_cache_policy_name
#   arquivos_cache_policy_default_ttl    = var.arquivos_cache_policy_default_ttl
# }

module "dns_records" {
  source                    = "../../modules/dns_records"
  root_zone_id              = module.dns_domain.zone_id
  domain_name               = var.domain_name
  cloudfront_domain_name    = "" # module.cdn.cloudfront_domain_name
  cloudfront_hosted_zone_id = "" # module.cdn.cloudfront_hosted_zone_id
  log_retention_in_days     = var.log_retention_in_days
  log_route53_group_name    = var.log_route53_group_name
  domain_log_policy         = var.domain_log_policy
  account_id                = data.aws_caller_identity.current.account_id
  aws_region                = data.aws_region.current.name
  kms_log_arn               = module.security.minhoteca_encrypt_cdn_log_arn
}
