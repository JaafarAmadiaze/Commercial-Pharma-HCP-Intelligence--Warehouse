
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select trx_count
from PHARMA_DW_DEV.MARTS.fact_prescription_claims
where trx_count is null



  
  
      
    ) dbt_internal_test