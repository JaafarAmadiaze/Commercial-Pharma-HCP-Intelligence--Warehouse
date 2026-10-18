
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select physician_id
from PHARMA_DW_DEV.MARTS.dim_physician
where physician_id is null



  
  
      
    ) dbt_internal_test