{{
    config(
        materialized='table',
        partition_by={
            "field": "event_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by=['event_name', 'user_pseudo_id'],
        require_partition_filter=true
    )
}}

with raw_sessions as (
    select * from `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    where _table_suffix between '20170701' and '20170731'
),

unnested_hits as (
    select
        parse_date('%Y%m%d', date) as event_date,
        fullVisitorId as user_pseudo_id,
        visitId,
        hit.eventInfo.eventCategory as event_name,
        hit.eventInfo.eventAction as event_action,
        hit.eventInfo.eventLabel as event_label,
        hit.eventInfo.eventValue as event_value,
        current_timestamp() as _loaded_at
    from raw_sessions,
    unnest(hits) as hit
    where hit.eventInfo is not null
)

select * from unnested_hits
