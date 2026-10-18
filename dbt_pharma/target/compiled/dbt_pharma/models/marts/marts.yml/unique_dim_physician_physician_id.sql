
    
    

select
    physician_id as unique_field,
    count(*) as n_records

from PHARMA_DW_DEV.MARTS.dim_physician
where physician_id is not null
group by physician_id
having count(*) > 1


