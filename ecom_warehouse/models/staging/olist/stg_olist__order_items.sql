with source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }} as order_item_key,
        order_id,
        order_item_id                as item_sequence,
        product_id,
        seller_id,
        shipping_limit_date          as shipping_limit_at,
        cast(price as numeric)                          as item_price,
        cast(freight_value as numeric)                  as freight_value,
        cast(price as numeric) + cast(freight_value as numeric)
                                                         as item_total

    from source

)

select * from renamed