{{
    config(
        materialized='table',
        partition_by={
            "field": "order_date",
            "data_type": "date",
            "granularity": "month"
        },
        partition_expiration_days=36500,
        cluster_by=['product_category', 'customer_state']
    )
}}

with orders as (

    select * from {{ ref('fct_orders') }}

),

daily as (

    select
        purchased_date                          as order_date,
        coalesce(primary_category, 'unknown')   as product_category,
        customer_state,

        count(distinct order_id)                as order_count,
        count(distinct customer_unique_id)      as customer_count,
        sum(item_revenue)                       as item_revenue,
        sum(freight_revenue)                    as freight_revenue,
        sum(total_revenue)                      as total_revenue,
        safe_divide(sum(total_revenue), count(distinct order_id))
                                                as avg_order_value,
        countif(is_late_delivery)               as late_delivery_count,
        avg(review_score)                       as avg_review_score,

        current_timestamp()                     as _dbt_updated_at

    from orders
    where is_cancelled = false
    group by 1, 2, 3

)

select * from daily