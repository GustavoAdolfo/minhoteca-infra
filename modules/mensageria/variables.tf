variable "projeto" {
  description = "Nome do projeto para prefixar os recursos"
  type        = string
  default     = "minhoteca"
}

variable "application_tags" {
  description = "Tags aplicadas a todos os recursos"
  type        = map(string)
}
