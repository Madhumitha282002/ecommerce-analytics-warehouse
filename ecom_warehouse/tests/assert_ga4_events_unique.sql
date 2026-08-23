select
    event_key,
    count(*) as occurrences
from {{ ref('stg_ga4__events') }}
where event_date >= date_sub(current_date(), interval 3650 day)
group by 1
having count(*) > 1