with source as (

    select * from {{ source('olist', 'closed_deals') }}

),

renamed as (

    select
        mql_id,
        seller_id,
        sdr_id,
        sr_id,
        won_date                                            as won_at,
        date(won_date)                                      as won_on,
        lower(trim(business_segment))                       as business_segment,
        lower(trim(lead_type))                              as lead_type,
        lower(trim(lead_behaviour_profile))                 as lead_behaviour_profile,
        lower(trim(business_type))                          as business_type,
        coalesce(lower(trim(has_company)) = 'true', false)  as has_company,
        coalesce(lower(trim(has_gtin)) = 'true', false)     as has_gtin,
        average_stock,
        declared_product_catalog_size,
        declared_monthly_revenue,
        _loaded_at

    from source

)

select * from renamed