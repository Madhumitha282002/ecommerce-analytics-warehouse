{{ config(materialized='table') }}

with funnel as (

    select * from {{ ref('int_marketing_funnel') }}

),

seller_performance as (

    select
        seller_id,
        count(distinct order_id) as orders_fulfilled,
        sum(item_total) as gmv_generated
    from {{ ref('int_order_items_enriched') }}
    group by 1

),

final as (

    select
        funnel.mql_id,
        funnel.first_contact_date,
        funnel.lead_origin,
        funnel.landing_page_id,
        funnel.is_converted,
        funnel.won_date,
        funnel.days_to_close,
        funnel.business_segment,
        funnel.lead_type,
        funnel.business_type,
        funnel.declared_monthly_revenue,
        funnel.seller_id,

        coalesce(seller_performance.orders_fulfilled, 0) as orders_fulfilled,
        coalesce(seller_performance.gmv_generated, 0) as gmv_generated,

        current_timestamp() as _dbt_updated_at

    from funnel
    left join seller_performance
        on funnel.seller_id = seller_performance.seller_id

)

select * from final
