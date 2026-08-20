with payments as (

    select * from {{ ref('stg_olist__order_payments') }}

),

aggregated as (

    select
        order_id,
        count(*)                                as payment_count,
        sum(payment_value)                      as total_payment_value,
        max(installment_count)                  as max_installments,
        array_agg(distinct payment_type ignore nulls order by payment_type)
                                                as payment_types,
        array_agg(payment_type order by payment_value desc limit 1)[offset(0)]
                                                as primary_payment_type

    from payments
    group by 1

)

select * from aggregated