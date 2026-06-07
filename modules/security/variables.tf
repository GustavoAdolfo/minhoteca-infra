variable "kms_verify_alias_name" { type = string }
variable "kms_verify_description" { type = string }
variable "domain_name" { type = string }
variable "application_tags" { type = map(string) }
variable "account_id" { type = string }
variable "kms_log_alias_name" { type = string }
variable "kms_log_description" { type = string }
variable "region" { type = string }
