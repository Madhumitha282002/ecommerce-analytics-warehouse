with items as (

    select * from {{ ref('stg_olist__order_items') }}

),

products as (

    select * from {{ ref('stg_olist__products') }}

),

sellers as (

    select * from {{ ref('stg_olist__sellers') }}

),

enriched as (

    select
        items.order_item_key,
        items.order_id,
        items.item_sequence,
        items.product_id,
        items.seller_id,
        products.category_name,
        products.product_weight_g,
        sellers.seller_state,
        sellers.seller_city,
        items.item_price,
        items.freight_value,
        items.item_total,
        items.shipping_limit_at

    from items
    left join products on items.product_id = products.product_id
    left join sellers on items.seller_id = sellers.seller_id

)

select * from enriched
