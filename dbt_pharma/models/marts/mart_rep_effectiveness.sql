{{ config(
    materialized='table',
    post_hook=[
      "ALTER TABLE {{ this }} ADD ROW ACCESS POLICY PHARMA_DW_DEV.GOVERNANCE.RAP_TERRITORY_RESTRICTION ON (territory_id)"
    ]
) }}

WITH call_metrics AS (
    SELECT
        rep_id,
        physician_id,
        territory_id,
        COUNT(call_id) AS total_visits,
        SUM(samples_dropped_count) AS total_samples_provided,
        AVG(call_sentiment_score) AS avg_sentiment_score,
        MODE(doctor_barrier_category) AS most_frequent_barrier
    FROM {{ ref('fact_field_calls') }}
    GROUP BY rep_id, physician_id, territory_id
),

hcp_rx_summary AS (
    SELECT
        physician_id,
        SUM(CASE WHEN is_our_brand THEN trx_count ELSE 0 END) AS our_brand_total_trx,
        SUM(CASE WHEN is_our_brand THEN total_gross_rx_value ELSE 0 END) AS our_brand_revenue
    FROM {{ ref('fact_prescription_claims') }}
    GROUP BY physician_id
)

SELECT
    c.rep_id,
    c.territory_id,
    c.physician_id,
    c.total_visits,
    c.total_samples_provided,
    ROUND(c.avg_sentiment_score, 3) AS avg_sentiment_score,
    c.most_frequent_barrier,
    COALESCE(rx.our_brand_total_trx, 0) AS our_brand_total_trx,
    COALESCE(rx.our_brand_revenue, 0) AS our_brand_revenue,
    ROUND(COALESCE(rx.our_brand_revenue, 0) / NULLIF(c.total_visits, 0), 2) AS revenue_per_visit
FROM call_metrics c
LEFT JOIN hcp_rx_summary rx ON c.physician_id = rx.physician_id
