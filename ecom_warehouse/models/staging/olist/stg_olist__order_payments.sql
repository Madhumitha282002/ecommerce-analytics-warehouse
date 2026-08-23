with source as (

    select * from {{ source('olist', 'order_payments') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'payment_sequential']) }} as payment_key,
        order_id,
        payment_sequential           as payment_sequence,
        lower(trim(payment_type))    as payment_type,
        payment_installments         as installment_count,
        cast(payment_value as numeric) as payment_value

    from source

)

select * from renamed