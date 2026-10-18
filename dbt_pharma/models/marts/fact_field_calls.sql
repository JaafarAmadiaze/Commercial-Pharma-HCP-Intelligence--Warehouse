{{ config(
    materialized='table',
    post_hook=[
      "ALTER TABLE {{ this }} ADD ROW ACCESS POLICY PHARMA_DW_DEV.GOVERNANCE.RAP_TERRITORY_RESTRICTION ON (territory_id)"
    ]
) }}

WITH calls AS (
    SELECT * FROM {{ ref('int_field_calls_enriched') }}
),
physicians AS (
    SELECT physician_id, territory_id FROM {{ ref('stg_physicians') }}
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
