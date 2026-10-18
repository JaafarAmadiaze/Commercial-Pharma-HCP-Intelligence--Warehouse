
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select claim_id
from PHARMA_DW_DEV.MARTS.fact_prescription_claims
where claim_id is null



  
  
      
    ) dbt_internal_test