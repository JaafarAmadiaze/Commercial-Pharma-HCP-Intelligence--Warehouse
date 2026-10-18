
      
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.snp_physicians
    
    
    
    
    

    as (
    

    select *,
        md5(coalesce(cast(physician_id as varchar ), '')
         || '|' || coalesce(cast(to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as varchar ), '')
        ) as dbt_scd_id,
        to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as dbt_updated_at,
        to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as dbt_valid_from,
        
  
  coalesce(nullif(to_timestamp_ntz(convert_timezone('UTC', current_timestamp())), to_timestamp_ntz(convert_timezone('UTC', current_timestamp()))), null)
  as dbt_valid_to
from (
        



SELECT
    physician_id,
    npi,
    first_name,
    last_name,
    specialty,
    state,
    territory_id
FROM PHARMA_DW_DEV.RAW.stg_physicians

    ) sbq



    )
;


  
  