# {{ config(materialized='view') }}

with items as (

    select * from {{ ref('int_order_items_enriched') }}

),

aggregated as (

    select
        order_id,
        count(*)                            as item_count,
        count(distinct product_id)          as distinct_product_count,
        count(distinct seller_id)           as seller_count,
        sum(item_price)                     as total_item_price,
        sum(freight_value)                  as total_freight_value,
        sum(item_total)                     as total_order_value,
        array_agg(distinct category_name ignore nulls order by category_name limit 1)[safe_offset(0)]
                                            as primary_category,
        any_value(seller_state)             as primary_seller_state

    from items
    group by 1

)

select * from aggregated