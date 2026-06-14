variable "account_id" {
  type        = string
  description = "AWS Account ID, used for bucket policies to allow CloudFront access"
}
variable "application_tags" {
  type        = map(string)
  description = "Map of tags to apply to all resources in the application"
}
variable "user_current_id" {
  type        = string
  description = "ID of the current AWS user, used for bucket ownership and permissions"
}
variable "bucket_frontend_name" {
  type        = string
  description = "Name of the S3 bucket to store the frontend application"
}
variable "bucket_frontend_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS configuration of the frontend bucket"
}
variable "bucket_arquivos_name" {
  type        = string
  description = "Name of the S3 bucket to store the arquivos for the frontend application"
}
variable "bucket_arquivos_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS configuration of the arquivos bucket"
}
