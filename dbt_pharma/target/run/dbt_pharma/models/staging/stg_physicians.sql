
  create or replace   view PHARMA_DW_DEV.RAW.stg_physicians
  
  
  
  
  as (
    WITH source AS (
    SELECT * FROM PHARMA_DW_DEV.RAW.raw_physicians
)
SELECT
    TRIM(physician_id) AS physician_id,
    TRIM(npi) AS npi,
    TRIM(dea_number) AS dea_number,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    TRIM(specialty) AS specialty,
    TRIM(phone_number) AS phone_number,
    LOWER(TRIM(email)) AS email,
    UPPER(TRIM(state)) AS state,
    UPPER(TRIM(territory_id)) AS territory_id,
    CURRENT_TIMESTAMP() AS loaded_at
FROM source
  );

