
  create or replace   view PHARMA_DW_DEV.RAW.stg_prescription_claims
  
  
  
  
  as (
    WITH source AS (
    SELECT * FROM PHARMA_DW_DEV.RAW.raw_prescription_claims
)
SELECT
    TRIM(claim_id) AS claim_id,
    TRIM(physician_id) AS physician_id,
    TRIM(product_id) AS product_id,
    UPPER(TRIM(territory_id)) AS territory_id,
    claim_date,
    COALESCE(nrx_count, 0) AS nrx_count,
    COALESCE(trx_count, 0) AS trx_count,
    CURRENT_TIMESTAMP() AS loaded_at
FROM source
  );

