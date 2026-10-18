
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.mart_brand_performance
    
    
    
    
    

    as (

WITH monthly_claims AS (
    SELECT
        DATE_TRUNC('month', f.claim_date) AS claim_month,
        f.territory_id,
        d.therapeutic_class,
        d.brand_name,
        d.is_our_brand,
        SUM(f.trx_count) AS brand_trx,
        SUM(f.nrx_count) AS brand_nrx,
        SUM(f.total_gross_rx_value) AS brand_revenue
    FROM PHARMA_DW_DEV.MARTS.fact_prescription_claims f
    JOIN PHARMA_DW_DEV.MARTS.dim_product d ON f.product_id = d.product_id
    GROUP BY 1, 2, 3, 4, 5
),

class_totals AS (
    SELECT
        claim_month,
        territory_id,
        therapeutic_class,
        SUM(brand_trx) AS total_class_trx
    FROM monthly_claims
    GROUP BY 1, 2, 3
)

SELECT
    m.claim_month,
    m.territory_id,
    m.therapeutic_class,
    m.brand_name,
    m.is_our_brand,
    m.brand_trx,
    m.brand_nrx,
    m.brand_revenue,
    t.total_class_trx,
    ROUND((m.brand_trx / NULLIF(t.total_class_trx, 0)) * 100, 2) AS market_share_percentage,
    ROUND((m.brand_nrx / NULLIF(m.brand_trx, 0)) * 100, 2) AS nrx_conversion_rate
FROM monthly_claims m
JOIN class_totals t 
    ON m.claim_month = t.claim_month
    AND m.territory_id = t.territory_id
    AND m.therapeutic_class = t.therapeutic_class
    )
;


  