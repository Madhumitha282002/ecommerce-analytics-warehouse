with orders as (

    select * from {{ ref('stg_olist__orders') }}

),

lifecycle as (

    select
        order_id,
        customer_id,
        order_status,
        purchased_at,
        purchased_date,
        approved_at,
        delivered_to_carrier_at,
        delivered_to_customer_at,
        estimated_delivery_at,

        timestamp_diff(approved_at, purchased_at, hour)
            as hours_to_approval,
        timestamp_diff(delivered_to_carrier_at, approved_at, hour)
            as hours_approval_to_carrier,
        timestamp_diff(delivered_to_customer_at, purchased_at, day)
            as days_purchase_to_delivery,
        timestamp_diff(delivered_to_customer_at, estimated_delivery_at, day)
            as days_delivery_vs_estimate,

        case
            when delivered_to_customer_at is null then null
            when delivered_to_customer_at > estimated_delivery_at then true
            else false
        end as is_late_delivery,

        case
            when order_status = 'delivered' then true
            else false
        end as is_delivered,

        case
            when order_status in ('canceled', 'unavailable') then true
            else false
        end as is_cancelled

    from orders

)

select * from lifecycle