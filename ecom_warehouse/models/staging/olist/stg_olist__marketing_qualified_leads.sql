with source as (

    select * from {{ source('olist', 'marketing_qualified_leads') }}

),

renamed as (

    select
        mql_id,
        first_contact_date,
        landing_page_id,
        coalesce(lower(trim(origin)), 'unknown') as lead_origin,
        _loaded_at

    from source

)

select * from renamed