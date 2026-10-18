
  
    

create or replace transient table PHARMA_DW_DEV.INTERMEDIATE.int_field_calls_enriched
    
    
    
    
    

    as (

WITH base_calls AS (
    SELECT * FROM PHARMA_DW_DEV.RAW.stg_field_calls
)

SELECT
    call_id,
    rep_id,
    physician_id,
    call_date,
    samples_dropped_count,
    discussion_notes,

    
    -- Heuristic classification mirroring Cortex categories for trial accounts
    CASE
        WHEN discussion_notes ILIKE '%co-pay%' OR discussion_notes ILIKE '%cost%' OR discussion_notes ILIKE '%reimbursement%' THEN 'Cost/Copay'
        WHEN discussion_notes ILIKE '%side effect%' OR discussion_notes ILIKE '%fatigue%' OR discussion_notes ILIKE '%gastrointestinal%' THEN 'Side Effects'
        WHEN discussion_notes ILIKE '%competitor%' OR discussion_notes ILIKE '%TumorStop%' OR discussion_notes ILIKE '%loyalty%' THEN 'Competitor Loyalty'
        WHEN discussion_notes ILIKE '%positive%' OR discussion_notes ILIKE '%efficacy%' OR discussion_notes ILIKE '%reprints%' THEN 'Efficacy'
        WHEN discussion_notes ILIKE '%formulary%' OR discussion_notes ILIKE '%discharge%' OR discussion_notes ILIKE '%insurance%' THEN 'Insurance/Formulary'
        ELSE 'Neutral'
    END AS doctor_barrier_category,

    CASE
        WHEN discussion_notes ILIKE '%positive%' OR discussion_notes ILIKE '%praised%' THEN 0.85
        WHEN discussion_notes ILIKE '%hesitation%' OR discussion_notes ILIKE '%concerned%' OR discussion_notes ILIKE '%side effect%' OR discussion_notes ILIKE '%not yet approved%' THEN -0.65
        ELSE 0.0
    END AS call_sentiment_score
    

FROM base_calls
    )
;


  