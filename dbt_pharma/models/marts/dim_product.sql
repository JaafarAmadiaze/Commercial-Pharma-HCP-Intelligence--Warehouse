{{ config(materialized='table') }}

SELECT
    product_id,
    brand_name,
    therapeutic_class,
    is_our_brand,
    wac_price
FROM {{ ref('stg_products') }}
