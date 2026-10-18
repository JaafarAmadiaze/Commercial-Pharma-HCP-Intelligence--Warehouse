
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select npi
from PHARMA_DW_DEV.MARTS.dim_physician
where npi is null



  
  
      
    ) dbt_internal_test