{{ config(materialized='table') }}

WITH base_calls AS (
    SELECT * FROM {{ ref('stg_field_calls') }}
)

SELECT
    call_id,
    rep_id,
    physician_id,
    call_date,
    samples_dropped_count,
    discussion_notes,

    {% if var('enable_cortex_llm', false) %}
    -- 1. Classification de l'objection principale via Snowflake Cortex LLM (Paid / Non-Trial accounts)
    TRIM(SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-8b', 
        CONCAT(
            'You are a pharma analytics assistant. Classify the main physician barrier in the following rep note into exactly one category: [Efficacy, Side Effects, Cost/Copay, Competitor Loyalty, Insurance/Formulary, Neutral]. Return ONLY the single chosen category name, nothing else: \n\n',
            discussion_notes
        )
    )) AS doctor_barrier_category,

    -- 2. Analyse de sentiment du médecin (-1.0 à +1.0)
    SNOWFLAKE.CORTEX.SENTIMENT(discussion_notes) AS call_sentiment_score
    {% else %}
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
    {% endif %}

FROM base_calls
