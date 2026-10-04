terraform {
  required_version = ">= 1.5.0"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.21.0"
    }
  }
}

provider "snowflake" {
  organization_name        = var.snowflake_organization_name
  account_name             = var.snowflake_account_name
  user                     = var.snowflake_user
  role                     = "TF_ADMIN"
  authenticator            = "SNOWFLAKE_JWT"
  private_key              = file(var.snowflake_private_key_path)
  preview_features_enabled = ["snowflake_table_resource"]
}