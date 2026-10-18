
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.dim_physician
    
    
    
    
    

    as (

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
FROM PHARMA_DW_DEV.RAW.stg_physicians
    )
;


  