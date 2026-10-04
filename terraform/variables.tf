variable "snowflake_organization_name" {
  type        = string
  description = "Snowflake Organization Name"
}

variable "snowflake_account_name" {
  type        = string
  description = "Snowflake Account Name"
}

variable "snowflake_user" {
  type        = string
  default     = "TF_SERVICE_USER"
  description = "Service user name for Terraform"
}

variable "snowflake_private_key_path" {
  type        = string
  default     = "C:/Users/dell/.snowflake/snowflake_tf_key.p8"
  description = "Path to the RSA private key file"
}

variable "environment" {
  type        = string
  default     = "DEV"
  description = "Deployment environment suffix"
}