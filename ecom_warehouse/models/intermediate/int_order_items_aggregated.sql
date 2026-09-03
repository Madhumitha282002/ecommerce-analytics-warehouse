{{ config(materialized='view') }}

with order_items as (

    select * from {{ ref('stg_olist__order_items') }}

),

products as (

    select * from {{ ref('stg_olist__products') }}

),

sellers as (

    select * from {{ ref('stg_olist__sellers') }}

),

aggregated as (

    select
        oi.order_id,
        count(distinct oi.order_item_key) as item_count,
        count(distinct oi.product_id) as distinct_product_count,
        count(distinct oi.seller_id) as seller_count,
        sum(oi.item_total) as total_order_value,
        sum(oi.item_price) as total_item_price,
        sum(oi.freight_value) as total_freight_value,
        array_agg(p.category_name order by oi.item_price desc limit 1)[offset(0)]
            as primary_category,
        array_agg(s.seller_state order by oi.item_price desc limit 1)[offset(0)]
            as primary_seller_state

    from order_items as oi
    left join products as p on oi.product_id = p.product_id
    left join sellers as s on oi.seller_id = s.seller_id
    group by 1

)

select * from aggregated
