{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ga4', 'events') }}
    where _table_suffix between '20201201' and '20210131'

),

flattened as (

    select
        parse_date('%Y%m%d', event_date)            as event_date,
        timestamp_micros(event_timestamp)           as event_at,
        event_name,
        user_pseudo_id,
        {{ dbt_utils.generate_surrogate_key([
            'user_pseudo_id', 'event_timestamp', 'event_name'
        ]) }}                                       as event_key,

        (select value.int_value from unnest(event_params)
         where key = 'ga_session_id')               as session_id,
        (select value.string_value from unnest(event_params)
         where key = 'page_title')                  as page_title,
        (select value.string_value from unnest(event_params)
         where key = 'page_location')               as page_location,
        (select value.string_value from unnest(event_params)
         where key = 'source')                      as traffic_source,
        (select value.string_value from unnest(event_params)
         where key = 'medium')                      as traffic_medium,
        (select value.string_value from unnest(event_params)
         where key = 'campaign')                    as campaign,
        (select value.int_value from unnest(event_params)
         where key = 'engagement_time_msec')        as engagement_time_msec,

        device.category                             as device_category,
        device.operating_system                     as operating_system,
        geo.country                                 as country,
        geo.region                                  as region,
        traffic_source.name                         as first_traffic_source,
        traffic_source.medium                       as first_traffic_medium,

        ecommerce.purchase_revenue_in_usd           as purchase_revenue_usd,
        ecommerce.total_item_quantity               as item_quantity,
        ecommerce.transaction_id

    from source

)

select * from flattened