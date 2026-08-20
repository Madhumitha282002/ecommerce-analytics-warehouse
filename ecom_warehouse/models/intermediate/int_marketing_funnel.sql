with leads as (

    select * from {{ ref('stg_olist__marketing_qualified_leads') }}

),

deals as (

    select * from {{ ref('stg_olist__closed_deals') }}

),

funnel as (

    select
        leads.mql_id,
        leads.first_contact_date,
        leads.origin                            as lead_origin,
        leads.landing_page_id,

        deals.seller_id,
        deals.won_date,
        deals.business_segment,
        deals.lead_type,
        deals.business_type,
        deals.declared_monthly_revenue,

        deals.mql_id is not null                as is_converted,

        date_diff(
            date(deals.won_date),
            leads.first_contact_date,
            day
        )                                       as days_to_close

    from leads
    left join deals on leads.mql_id = deals.mql_id

)

select * from funnel