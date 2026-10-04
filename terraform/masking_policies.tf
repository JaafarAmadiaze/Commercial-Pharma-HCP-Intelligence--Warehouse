# Mask DEA Number (Shows first 2 characters, masks the remaining digits)
resource "snowflake_masking_policy" "dea_mask" {
  name               = "MASK_DEA_NUMBER"
  database           = snowflake_database.pharma_dw.name
  schema             = snowflake_schema.governance.name
  return_data_type   = "VARCHAR"

  argument {
    name = "val"
    type = "VARCHAR"
  }

  body = <<-EOT
    CASE 
      WHEN CURRENT_ROLE() IN ('COMPLIANCE_OFFICER_${var.environment}', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 2), '*****', RIGHT(val, 2))
    END
  EOT
}

# Mask Physician Phone Number (Preserves only last 4 digits)
resource "snowflake_masking_policy" "phone_mask" {
  name               = "MASK_PHONE_NUMBER"
  database           = snowflake_database.pharma_dw.name
  schema             = snowflake_schema.governance.name
  return_data_type   = "VARCHAR"

  argument {
    name = "val"
    type = "VARCHAR"
  }

  body = <<-EOT
    CASE 
      WHEN CURRENT_ROLE() IN ('COMPLIANCE_OFFICER_${var.environment}', 'ACCOUNTADMIN') THEN val
      ELSE '***-***-' || RIGHT(val, 4)
    END
  EOT
}

# Mask Physician Personal Email Address
resource "snowflake_masking_policy" "email_mask" {
  name               = "MASK_EMAIL"
  database           = snowflake_database.pharma_dw.name
  schema             = snowflake_schema.governance.name
  return_data_type   = "VARCHAR"

  argument {
    name = "val"
    type = "VARCHAR"
  }

  body = <<-EOT
    CASE 
      WHEN CURRENT_ROLE() IN ('COMPLIANCE_OFFICER_${var.environment}', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 1), '***@', SPLIT_PART(val, '@', 2))
    END
  EOT
}
