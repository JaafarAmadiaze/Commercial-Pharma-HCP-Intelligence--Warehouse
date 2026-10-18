{{ config(
    materialized='table',
    post_hook=[
      "ALTER TABLE {{ this }} MODIFY COLUMN DEA_NUMBER SET MASKING POLICY PHARMA_DW_DEV.GOVERNANCE.MASK_DEA_NUMBER",
      "ALTER TABLE {{ this }} MODIFY COLUMN PHONE_NUMBER SET MASKING POLICY PHARMA_DW_DEV.GOVERNANCE.MASK_PHONE_NUMBER",
      "ALTER TABLE {{ this }} MODIFY COLUMN EMAIL SET MASKING POLICY PHARMA_DW_DEV.GOVERNANCE.MASK_EMAIL",
      "ALTER TABLE {{ this }} ADD ROW ACCESS POLICY PHARMA_DW_DEV.GOVERNANCE.RAP_TERRITORY_RESTRICTION ON (territory_id)"
    ]
) }}

SELECT
    physician_id,
    npi,
    dea_number,
    first_name,
    last_name,
    specialty,
    phone_number,
    email,
    state,
    territory_id
FROM {{ ref('stg_physicians') }}
