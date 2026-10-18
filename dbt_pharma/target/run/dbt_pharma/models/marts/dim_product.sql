
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.dim_product
    
    
    
    
    

    as (

SELECT
    product_id,
    brand_name,
    therapeutic_class,
    is_our_brand,
    wac_price
FROM PHARMA_DW_DEV.RAW.stg_products
    )
;


  