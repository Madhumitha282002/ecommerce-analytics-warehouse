{{
    config(
        materialized='table',
        partition_by={
            "field": "purchased_date",
            "data_type": "date",
            "granularity": "month"
        },
        partition_expiration_days=36500,
        cluster_by=['order_status', 'customer_state']
    )
}}
with lifecycle as (
    select * from {{ ref('int_order_lifecycle') }}
),
items as (
    select * from {{ ref('int_order_items_aggregated') }}
),
payments as (
    select * from {{ ref('int_order_payments_aggregated') }}
),
customers as (
    select * from {{ ref('stg_olist__customers') }}
),
reviews as (
    select
        order_id,
        avg(review_score) as review_score
    from {{ ref('stg_olist__order_reviews') }}
    group by 1
),
final as (
    select
        lifecycle.order_id,
        lifecycle.customer_id,
        customers.customer_unique_id,
        customers.customer_state,
        customers.customer_city,
        lifecycle.order_status,
        lifecycle.purchased_at,
        lifecycle.purchased_date,
        lifecycle.delivered_to_customer_at,
        lifecycle.estimated_delivery_at,
        coalesce(items.item_count, 0)               as item_count,
        coalesce(items.distinct_product_count, 0)   as distinct_product_count,
        coalesce(items.seller_count, 0)             as seller_count,
        items.primary_category,
        items.primary_seller_state,
        coalesce(items.total_item_price, 0)         as item_revenue,
        coalesce(items.total_freight_value, 0)      as freight_revenue,
        coalesce(items.total_order_value, 0)        as total_revenue,
        payments.primary_payment_type               as payment_type,
        payments.payment_count,
        payments.max_installments,
        payments.total_payment_value,
        lifecycle.days_purchase_to_delivery,
        lifecycle.days_delivery_vs_estimate,
        lifecycle.is_late_delivery,
        lifecycle.is_delivered,
        lifecycle.is_cancelled,
        reviews.review_score,
        current_timestamp()                         as _dbt_updated_at
    from lifecycle
    left join items on lifecycle.order_id = items.order_id
    left join payments on lifecycle.order_id = payments.order_id
    left join customers on lifecycle.customer_id = customers.customer_id
    left join reviews on lifecycle.order_id = reviews.order_id
)
select * from final
