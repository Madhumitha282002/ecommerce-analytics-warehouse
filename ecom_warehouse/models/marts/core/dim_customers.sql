{{ config(materialized='table') }}

with customers as (

    select * from {{ ref('stg_olist__customers') }}

),

geolocation as (

    select * from {{ ref('stg_olist__geolocation') }}

),

orders as (

    select * from {{ ref('fct_orders') }}

),

customer_orders as (

    select
        customer_unique_id,
        count(distinct order_id) as lifetime_order_count,
        sum(total_revenue) as lifetime_revenue,
        avg(total_revenue) as avg_order_value,
        min(purchased_date) as first_order_date,
        max(purchased_date) as most_recent_order_date,
        avg(review_score) as avg_review_score,
        countif(is_late_delivery) as late_delivery_count

    from orders
    group by 1

),

final as (

    select
        customers.customer_unique_id,
        any_value(customers.customer_state) as customer_state,
        any_value(customers.customer_city) as customer_city,
        any_value(customers.customer_zip_code_prefix) as zip_code_prefix,
        any_value(geolocation.latitude) as latitude,
        any_value(geolocation.longitude) as longitude,

        coalesce(any_value(customer_orders.lifetime_order_count), 0)
            as lifetime_order_count,
        coalesce(any_value(customer_orders.lifetime_revenue), 0)
            as lifetime_revenue,
        any_value(customer_orders.avg_order_value) as avg_order_value,
        any_value(customer_orders.first_order_date) as first_order_date,
        any_value(customer_orders.most_recent_order_date) as most_recent_order_date,
        any_value(customer_orders.avg_review_score) as avg_review_score,
        coalesce(any_value(customer_orders.late_delivery_count), 0)
            as late_delivery_count,

        case
            when any_value(customer_orders.lifetime_order_count) > 1
                then 'repeat'
            else 'one_time'
        end as customer_segment,

        date_diff(
            current_date(),
            any_value(customer_orders.most_recent_order_date),
            day
        ) as days_since_last_order,

        current_timestamp() as _dbt_updated_at

    from customers
    left join geolocation
        on customers.customer_zip_code_prefix = geolocation.zip_code_prefix
    left join customer_orders
        on customers.customer_unique_id = customer_orders.customer_unique_id
    group by 1

)

select * from final
