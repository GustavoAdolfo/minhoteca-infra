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
  root_zone_id                                 = module.dns_domain.root_zone_id
}


module "buckets" {
  source                           = "../../modules/buckets"
  bucket_frontend_name             = var.bucket_frontend_name
  bucket_resources_name            = var.bucket_resources_name
  bucket_frontend_allowed_origins  = var.bucket_frontend_allowed_origins
  bucket_resources_allowed_origins = var.bucket_resources_allowed_origins
  application_tags                 = module.appservice.appregistry_tags
  user_current_id                  = data.aws_canonical_user_id.current.id
}
