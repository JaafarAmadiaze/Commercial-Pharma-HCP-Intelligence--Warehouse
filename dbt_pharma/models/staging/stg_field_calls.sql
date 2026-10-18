WITH source AS (
    SELECT * FROM {{ source('raw_pharma', 'raw_field_calls') }}
)
SELECT
    TRIM(call_id) AS call_id,
    TRIM(rep_id) AS rep_id,
    TRIM(physician_id) AS physician_id,
    call_date,
    COALESCE(samples_dropped_count, 0) AS samples_dropped_count,
    TRIM(discussion_notes) AS discussion_notes,
    CURRENT_TIMESTAMP() AS loaded_at
FROM source
