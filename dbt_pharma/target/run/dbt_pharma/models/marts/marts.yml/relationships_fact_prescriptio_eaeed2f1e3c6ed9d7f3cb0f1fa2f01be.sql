
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select physician_id as from_field
    from PHARMA_DW_DEV.MARTS.fact_prescription_claims
    where physician_id is not null
),

parent as (
    select physician_id as to_field
    from PHARMA_DW_DEV.MARTS.dim_physician
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test