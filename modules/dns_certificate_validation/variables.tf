variable "acm_certificate_minhoteca_validation_options" {
  type = list(object({
    domain_name = string
    # validation_method = string
    resource_record = object({
      name   = string
      type   = string
      value  = string
      ttl    = number
      weight = number
    })
  }))
}
variable "certificate_minhoteca_arn" { type = string }
variable "root_zone_id" { type = string }
