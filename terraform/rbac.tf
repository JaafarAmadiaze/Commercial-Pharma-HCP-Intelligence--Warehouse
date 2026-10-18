# --- Functional Roles ---
resource "snowflake_account_role" "data_engineer" {
  name    = "DATA_ENGINEER_${var.environment}"
  comment = "Owns transformation pipelines, dbt runs, and schema management"
}

resource "snowflake_account_role" "compliance_officer" {
  name    = "COMPLIANCE_OFFICER_${var.environment}"
  comment = "Can inspect raw PII, unmasked DEA licenses, and audit logs"
}

resource "snowflake_account_role" "commercial_rep" {
  name    = "COMMERCIAL_REP_${var.environment}"
  comment = "Field reps and managers: read-only access restricted by RLAP"
}

# --- Warehouse Grants ---
resource "snowflake_grant_privileges_to_account_role" "wh_usage_de" {
  account_role_name = snowflake_account_role.data_engineer.name
  privileges        = ["USAGE", "OPERATE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.pharma_wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "wh_usage_rep" {
  account_role_name = snowflake_account_role.commercial_rep.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.pharma_wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "wh_usage_compliance" {
  account_role_name = snowflake_account_role.compliance_officer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.pharma_wh.name
  }
}

# --- Database & Schema Grants ---
# 1. Data Engineer has full operating privileges in DEV
resource "snowflake_grant_privileges_to_account_role" "de_db_usage" {
  account_role_name = snowflake_account_role.data_engineer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.pharma_dw.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "de_schema_all" {
  for_each          = toset([snowflake_schema.raw.name, snowflake_schema.governance.name, snowflake_schema.marts.name])
  account_role_name = snowflake_account_role.data_engineer.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  on_schema {
    schema_name = "\"${snowflake_database.pharma_dw.name}\".\"${each.value}\""
  }
}

# 2. Commercial Rep & Compliance Officer can read analytical marts
resource "snowflake_grant_privileges_to_account_role" "rep_db_usage" {
  account_role_name = snowflake_account_role.commercial_rep.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.pharma_dw.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "rep_marts_usage" {
  account_role_name = snowflake_account_role.commercial_rep.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "\"${snowflake_database.pharma_dw.name}\".\"${snowflake_schema.marts.name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "rep_marts_select" {
  account_role_name = snowflake_account_role.commercial_rep.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.pharma_dw.name}\".\"${snowflake_schema.marts.name}\""
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_db_usage" {
  account_role_name = snowflake_account_role.compliance_officer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.pharma_dw.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_marts_usage" {
  account_role_name = snowflake_account_role.compliance_officer.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "\"${snowflake_database.pharma_dw.name}\".\"${snowflake_schema.marts.name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "compliance_marts_select" {
  account_role_name = snowflake_account_role.compliance_officer.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.pharma_dw.name}\".\"${snowflake_schema.marts.name}\""
    }
  }
}

# --- Grant Functional Roles to Current User for Simulation ---
resource "snowflake_grant_account_role" "grant_compliance_to_user" {
  role_name = snowflake_account_role.compliance_officer.name
  user_name = var.snowflake_user
}

resource "snowflake_grant_account_role" "grant_rep_to_user" {
  role_name = snowflake_account_role.commercial_rep.name
  user_name = var.snowflake_user
}

resource "snowflake_grant_account_role" "grant_de_to_user" {
  role_name = snowflake_account_role.data_engineer.name
  user_name = var.snowflake_user
}

