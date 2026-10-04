# Compute Warehouse for Transformations & Cortex LLM
resource "snowflake_warehouse" "pharma_wh" {
  name           = "PHARMA_WH_${var.environment}"
  warehouse_size = "X-SMALL"
  auto_suspend   = 60
  auto_resume    = true
  initially_suspended = true
  comment        = "Warehouse for pharma commercial analytics and dbt jobs"
}

# Core Analytical Database
resource "snowflake_database" "pharma_dw" {
  name    = "PHARMA_DW_${var.environment}"
  comment = "Primary data warehouse for HCP commercial analytics"
}

# Raw Ingestion Schema (Claims, Rep logs, MDM Prescriber data)
resource "snowflake_schema" "raw" {
  database = snowflake_database.pharma_dw.name
  name     = "RAW"
  comment  = "Bronze / Ingestion layer"
}

# Governance Schema (Houses Security Policies, Masking, & Territory Mapping)
resource "snowflake_schema" "governance" {
  database = snowflake_database.pharma_dw.name
  name     = "GOVERNANCE"
  comment  = "Houses masking policies and territory authorization tables"
}

# Analytics Marts Schema (Final conformed star schema)
resource "snowflake_schema" "marts" {
  database = snowflake_database.pharma_dw.name
  name     = "MARTS"
  comment  = "Gold layer / Conformed star schema for BI and Streamlit"
}