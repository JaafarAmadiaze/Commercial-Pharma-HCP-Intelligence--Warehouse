{% snapshot snp_physicians %}

{{
    config(
      target_database='PHARMA_DW_DEV',
      target_schema='MARTS',
      unique_key='physician_id',
      strategy='check',
      check_cols=['territory_id', 'state', 'specialty']
    )
}}

SELECT
    physician_id,
    npi,
    first_name,
    last_name,
    specialty,
    state,
    territory_id
FROM {{ ref('stg_physicians') }}

{% endsnapshot %}
