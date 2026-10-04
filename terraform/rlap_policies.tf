# Seed table storing user-to-territory assignments
resource "snowflake_table" "user_territory_map" {
  database = snowflake_database.pharma_dw.name
  schema   = snowflake_schema.governance.name
  name     = "USER_TERRITORY_MAP"
  comment  = "Maps representative usernames to assigned sales territories"

  column {
    name = "USER_NAME"
    type = "VARCHAR(100)"
  }

  column {
    name = "TERRITORY_ID"
    type = "VARCHAR(50)"
  }
}

# Grant read access on the mapping table so policies evaluate correctly
resource "snowflake_grant_privileges_to_account_role" "read_territory_map" {
  for_each          = toset([snowflake_account_role.commercial_rep.name, snowflake_account_role.data_engineer.name])
  account_role_name = each.value
  privileges        = ["SELECT"]
  on_schema_object {
    object_type = "TABLE"
    object_name = "\"${snowflake_database.pharma_dw.name}\".\"${snowflake_schema.governance.name}\".\"${snowflake_table.user_territory_map.name}\""
  }
}

# Row Access Policy evaluated on any table or view with a territory_id column
resource "snowflake_row_access_policy" "territory_rlap" {
  name       = "RAP_TERRITORY_RESTRICTION"
  database   = snowflake_database.pharma_dw.name
  schema     = snowflake_schema.governance.name
  depends_on = [snowflake_table.user_territory_map]

  argument {
    name = "territory_id"
    type = "VARCHAR"
  }

  body = <<-EOT
    CURRENT_ROLE() IN ('ACCOUNTADMIN', 'COMPLIANCE_OFFICER_${var.environment}', 'DATA_ENGINEER_${var.environment}')
    OR EXISTS (
      SELECT 1 
      FROM ${snowflake_database.pharma_dw.name}.${snowflake_schema.governance.name}.USER_TERRITORY_MAP map
      WHERE UPPER(map.user_name) = UPPER(CURRENT_USER())
        AND map.territory_id = territory_id
    )
  EOT
}
