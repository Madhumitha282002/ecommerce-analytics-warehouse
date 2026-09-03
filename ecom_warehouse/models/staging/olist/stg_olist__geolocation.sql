with source as (

    select * from {{ source('olist', 'geolocation') }}

),

deduplicated as (

    select
        lpad(geolocation_zip_code_prefix, 5, '0') as zip_code_prefix,
        avg(geolocation_lat) as latitude,
        avg(geolocation_lng) as longitude,
        any_value(geolocation_state) as state

    from source
    group by 1

)

select * from deduplicated
