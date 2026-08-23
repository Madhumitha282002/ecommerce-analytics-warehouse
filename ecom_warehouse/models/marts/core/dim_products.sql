{{ config(materialized='table') }}

with products as (

    select * from {{ ref('stg_olist__products') }}

),

product_sales as (

    select
        product_id,
        count(distinct order_id)    as order_count,
        sum(item_total)             as total_revenue,
        avg(item_price)             as avg_selling_price
    from {{ ref('int_order_items_enriched') }}
    group by 1

),

final as (

    select
        products.product_id,
        products.category_name,
        products.category_name_pt,
        products.product_weight_g,
        products.product_volume_cm3,
        products.product_photo_count,

        coalesce(product_sales.order_count, 0)      as order_count,
        coalesce(product_sales.total_revenue, 0)    as total_revenue,
        product_sales.avg_selling_price,

        current_timestamp()                         as _dbt_updated_at

    from products
    left join product_sales
        on products.product_id = product_sales.product_id

)

select * from final