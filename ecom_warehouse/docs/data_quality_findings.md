# Data Quality Findings

## 1. Order fan-out inflating revenue by 18%

Joining orders to order_items and order_payments directly produced
R$ X in revenue against a true figure of R$ Y, an 18% overstatement.
Orders with multiple items and multiple payment records produced a
cartesian expansion.

Fix: aggregate items and payments to order grain independently in the
intermediate layer, then join at order grain in fct_orders.

## 2. Duplicate review_id values

The order_reviews source contains N duplicate review_id values.
Deduplicated in staging by keeping the most recent review_answer_timestamp
per review_id.

## 3. Payment value does not reconcile to order value

N orders show a discrepancy above R$1.00 between total item value plus
freight and total payment value. Root cause is voucher application and
installment interest, neither of which is present in the item tables.
Test retained at warn severity with a threshold of 100 rows.

## 4. Products missing category

N products have a null product_category_name. Mapped to 'unknown' in
staging rather than dropped, to preserve revenue attribution totals.

## 5. Geolocation duplication

The geolocation source has one row per coordinate pair, not per postal
prefix. Collapsed to one row per prefix using coordinate centroids.


### Orphaned Sellers (462 records)
Sellers in closed_deals not in stg_olist__sellers

### Payment Mismatch (1348 records)  
Orders where total_payment_value != total_revenue