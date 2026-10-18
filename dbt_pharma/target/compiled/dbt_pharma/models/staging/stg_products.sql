WITH source AS (
    SELECT * FROM PHARMA_DW_DEV.RAW.raw_products
)
SELECT
    TRIM(product_id) AS product_id,
    TRIM(brand_name) AS brand_name,
    TRIM(therapeutic_class) AS therapeutic_class,
    is_our_brand,
    wac_price,
    CURRENT_TIMESTAMP() AS loaded_at
FROM source