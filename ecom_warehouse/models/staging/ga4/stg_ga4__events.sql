{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={
        "field": "event_date",
        "data_type": "date",
        "granularity": "day"
    },
    cluster_by=['event_name', 'user_pseudo_id'],
    partition_expiration_days=9999
) }}

select
    parse_date('%Y%m%d', date) as event_date,
    fullVisitorId as user_pseudo_id,
    visitId,
    hit.eventInfo.eventCategory as event_name,
    hit.eventInfo.eventAction as event_action,
    hit.eventInfo.eventValue as event_value,
    hit.eventInfo.eventLabel as event_label,
    current_timestamp() as _loaded_at
from `bigquery-public-data.google_analytics_sample.ga_sessions_20170701`,
unnest(hits) as hit
where hit.eventInfo is not null
  and date is not null
  and parse_date('%Y%m%d', date) is not null
  {% if is_incremental() %}
    and parse_date('%Y%m%d', date) >= date_sub(current_date(), interval 3 day)
  {% endif %}
