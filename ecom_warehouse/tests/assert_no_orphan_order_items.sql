select items.order_id
from {{ ref('stg_olist__order_items') }} items
left join {{ ref('stg_olist__orders') }} orders
    on items.order_id = orders.order_id
where orders.order_id is null