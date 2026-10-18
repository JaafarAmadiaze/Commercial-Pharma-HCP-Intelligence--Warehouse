
    
    

select
    npi as unique_field,
    count(*) as n_records

from PHARMA_DW_DEV.MARTS.dim_physician
where npi is not null
group by npi
having count(*) > 1


