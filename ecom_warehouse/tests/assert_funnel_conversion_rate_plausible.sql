with rate as (

    select
        safe_divide(countif(is_converted), count(*)) as conversion_rate
    from {{ ref('fct_marketing_funnel') }}

)

select *
from rate
where conversion_rate <= 0 or conversion_rate >= 0.50