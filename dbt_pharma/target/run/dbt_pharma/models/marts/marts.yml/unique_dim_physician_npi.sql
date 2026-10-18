
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    npi as unique_field,
    count(*) as n_records

from PHARMA_DW_DEV.MARTS.dim_physician
where npi is not null
group by npi
having count(*) > 1



  
  
      
    ) dbt_internal_test