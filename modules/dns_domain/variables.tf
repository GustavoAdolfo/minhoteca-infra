variable "domain_name" { type = string }
variable "dnssec_name" { type = string }
variable "application_tags" { type = map(string) }
variable "enable_dnssec" {
  type    = bool
  default = false
}
variable "kms_dns_verify_arn" {
  type = string
}
