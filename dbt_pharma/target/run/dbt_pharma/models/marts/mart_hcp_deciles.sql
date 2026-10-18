
  
    

create or replace transient table PHARMA_DW_DEV.MARTS.mart_hcp_deciles
    
    
    
    
    

    as (

WITH hcp_volumes AS (
    SELECT
        f.physician_id,
        p.territory_id,
        p.specialty,
        d.therapeutic_class,
        SUM(f.trx_count) AS total_trx,
        SUM(f.nrx_count) AS total_nrx,
        SUM(f.total_gross_rx_value) AS total_rx_revenue,
        SUM(CASE WHEN f.is_our_brand THEN f.trx_count ELSE 0 END) AS our_brand_trx
    FROM PHARMA_DW_DEV.MARTS.fact_prescription_claims f
    JOIN PHARMA_DW_DEV.MARTS.dim_physician p ON f.physician_id = p.physician_id
    JOIN PHARMA_DW_DEV.MARTS.dim_product d ON f.product_id = d.product_id
    GROUP BY f.physician_id, p.territory_id, p.specialty, d.therapeutic_class
),

ranked_hcps AS (
    SELECT
        *,
        NTILE(10) OVER (
            PARTITION BY therapeutic_class 
            ORDER BY total_trx ASC
        ) AS hcp_decile
    FROM hcp_volumes
)

SELECT
    physician_id,
    territory_id,
    specialty,
    therapeutic_class,
    total_trx,
    total_nrx,
    our_brand_trx,
    total_rx_revenue,
    hcp_decile,
    CASE 
        WHEN hcp_decile >= 8 THEN 'Tier 1 (High Priority)'
        WHEN hcp_decile >= 5 THEN 'Tier 2 (Medium Priority)'
        ELSE 'Tier 3 (Low Priority)'
    END AS commercial_tier
FROM ranked_hcps
    )
;


  