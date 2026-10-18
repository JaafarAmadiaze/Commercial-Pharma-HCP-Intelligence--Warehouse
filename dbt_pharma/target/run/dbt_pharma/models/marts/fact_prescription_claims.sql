
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.fact_prescription_claims
    
    
    
    
    

    as (

WITH claims AS (
    SELECT * FROM PHARMA_DW_DEV.RAW.stg_prescription_claims
),
products AS (
    SELECT product_id, wac_price, is_our_brand FROM PHARMA_DW_DEV.RAW.stg_products
)

SELECT
    c.claim_id,
    c.physician_id,
    c.product_id,
    c.territory_id,
    c.claim_date,
    c.nrx_count,
    c.trx_count,
    (c.trx_count * prd.wac_price) AS total_gross_rx_value,
    prd.is_our_brand
FROM claims c
LEFT JOIN products prd ON c.product_id = prd.product_id
    )
;


  