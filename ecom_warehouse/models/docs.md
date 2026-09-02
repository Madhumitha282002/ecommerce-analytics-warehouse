{% docs order_grain %}
One row per order. Item-level and payment-level detail is pre-aggregated
in the intermediate layer (`int_order_items_aggregated`,
`int_order_payments_aggregated`) before being joined in, so this table
never fans out even though an order can have many items and many
payment installments.
{% enddocs %}

{% docs customer_id_vs_unique_id %}
The source system issues a new `customer_id` for every order a shopper
places, so `customer_id` is not a stable person-level key — joining or
grouping on it makes every customer look like a one-time buyer.
`customer_unique_id` is the person-level identifier and is what all
repeat-purchase, lifetime-value, and retention logic groups on. Staging
and `fct_orders` carry `customer_id` because it is the natural join key
back to the order; anything measuring customer behavior over time uses
`customer_unique_id` instead.
{% enddocs %}

{% docs late_delivery_definition %}
True when `delivered_to_customer_at` exceeds `estimated_delivery_at`.
Null when the order has not been delivered yet. Deliberately not
coerced to false, since doing so would understate the late-delivery
rate by silently treating undelivered orders as on-time.
{% enddocs %}

{% docs is_cancelled_definition %}
True when `order_status` is `canceled` or `unavailable`. These are
grouped together because both mean the order will never be fulfilled;
downstream revenue aggregates (`agg_daily_revenue`) exclude them so
that cancelled orders don't inflate demand or revenue figures.
{% enddocs %}

{% docs review_dedup %}
The source `order_reviews` table contains repeated `review_id` values
(the same review updated more than once). This model keeps only the
most recent row per `review_id`, ranked by `review_answer_timestamp`,
so the grain is one row per review rather than one row per review
revision.
{% enddocs %}

{% docs product_category_unknown %}
Category is translated from the Portuguese source value via a lookup
table. Not every source category has a translation, and some products
have no category at all; both cases coalesce to the literal string
`'unknown'` rather than null, so category can always be used as a
`group by` key without rows silently disappearing from category-level
aggregates.
{% enddocs %}

{% docs customer_segment_definition %}
`'repeat'` when a customer's lifetime order count is greater than 1,
otherwise `'one_time'`. Computed from `fct_orders`, so it reflects all
orders regardless of status — a customer with one delivered order and
one cancelled order still counts as having placed 2 orders here.
{% enddocs %}

{% docs surrogate_key_reason %}
The source has no natural single-column primary key at this grain, so
the key is hashed from the columns that do define the grain. Two rows
with identical values across those columns will collide by design —
that's what makes this a surrogate key for the grain rather than an
arbitrary row identifier.
{% enddocs %}

{% docs dbt_updated_at %}
Timestamp this row was last built by dbt. Reflects when the model last
ran, not when the underlying business event occurred — do not use this
for time-series analysis.
{% enddocs %}
