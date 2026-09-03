-- Reconciliation query
select
    (select sum(total_revenue) from `ecommerce-warehouse-505720.analytics.fct_orders` where is_cancelled = false) as fct_orders_total,
    (select sum(total_revenue) from `ecommerce-warehouse-505720.analytics.agg_daily_revenue`) as agg_daily_total;

-- Row counts by layer
select 'raw' as layer, count(*) as row_count from `ecommerce-warehouse-505720.raw.olist_orders_dataset` union all
select 'staging', count(*) from `ecommerce-warehouse-505720.staging.stg_olist__orders` union all
select 'analytics', count(*) from `ecommerce-warehouse-505720.analytics.fct_orders`;

-- Data freshness
select max(_loaded_at) as latest_load from `ecommerce-warehouse-505720.raw.olist_orders_dataset`;
