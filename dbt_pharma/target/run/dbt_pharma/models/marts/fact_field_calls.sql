
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.fact_field_calls
    
    
    
    
    

    as (

WITH calls AS (
    SELECT * FROM PHARMA_DW_DEV.INTERMEDIATE.int_field_calls_enriched
),
physicians AS (
    SELECT physician_id, territory_id FROM PHARMA_DW_DEV.RAW.stg_physicians
)

SELECT
    c.call_id,
    c.rep_id,
    c.physician_id,
    p.territory_id,
    c.call_date,
    c.samples_dropped_count,
    c.doctor_barrier_category,
    c.call_sentiment_score,
    c.discussion_notes
FROM calls c
LEFT JOIN physicians p ON c.physician_id = p.physician_id
    )
;


  