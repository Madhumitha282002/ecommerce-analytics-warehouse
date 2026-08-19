from google.cloud import bigquery

STR = bigquery.enums.SqlTypeNames.STRING
INT = bigquery.enums.SqlTypeNames.INTEGER
FLT = bigquery.enums.SqlTypeNames.FLOAT
TS = bigquery.enums.SqlTypeNames.TIMESTAMP
DATE = bigquery.enums.SqlTypeNames.DATE


def f(name, ftype, mode="NULLABLE"):
    return bigquery.SchemaField(name, ftype, mode=mode)


SCHEMAS = {
    "customers": {
        "file": "olist_customers_dataset.csv",
        "schema": [
            f("customer_id", STR, "REQUIRED"),
            f("customer_unique_id", STR),
            f("customer_zip_code_prefix", STR),
            f("customer_city", STR),
            f("customer_state", STR),
        ],
    },
    "geolocation": {
        "file": "olist_geolocation_dataset.csv",
        "schema": [
            f("geolocation_zip_code_prefix", STR),
            f("geolocation_lat", FLT),
            f("geolocation_lng", FLT),
            f("geolocation_city", STR),
            f("geolocation_state", STR),
        ],
    },
    "order_items": {
        "file": "olist_order_items_dataset.csv",
        "schema": [
            f("order_id", STR, "REQUIRED"),
            f("order_item_id", INT, "REQUIRED"),
            f("product_id", STR),
            f("seller_id", STR),
            f("shipping_limit_date", TS),
            f("price", FLT),
            f("freight_value", FLT),
        ],
    },
    "order_payments": {
        "file": "olist_order_payments_dataset.csv",
        "schema": [
            f("order_id", STR, "REQUIRED"),
            f("payment_sequential", INT),
            f("payment_type", STR),
            f("payment_installments", INT),
            f("payment_value", FLT),
        ],
    },
    "order_reviews": {
        "file": "olist_order_reviews_dataset.csv",
        "schema": [
            f("review_id", STR),
            f("order_id", STR),
            f("review_score", INT),
            f("review_comment_title", STR),
            f("review_comment_message", STR),
            f("review_creation_date", TS),
            f("review_answer_timestamp", TS),
        ],
    },
    "orders": {
        "file": "olist_orders_dataset.csv",
        "schema": [
            f("order_id", STR, "REQUIRED"),
            f("customer_id", STR),
            f("order_status", STR),
            f("order_purchase_timestamp", TS),
            f("order_approved_at", TS),
            f("order_delivered_carrier_date", TS),
            f("order_delivered_customer_date", TS),
            f("order_estimated_delivery_date", TS),
        ],
    },
    "products": {
        "file": "olist_products_dataset.csv",
        "schema": [
            f("product_id", STR, "REQUIRED"),
            f("product_category_name", STR),
            f("product_name_lenght", INT),
            f("product_description_lenght", INT),
            f("product_photos_qty", INT),
            f("product_weight_g", INT),
            f("product_length_cm", INT),
            f("product_height_cm", INT),
            f("product_width_cm", INT),
        ],
    },
    "sellers": {
        "file": "olist_sellers_dataset.csv",
        "schema": [
            f("seller_id", STR, "REQUIRED"),
            f("seller_zip_code_prefix", STR),
            f("seller_city", STR),
            f("seller_state", STR),
        ],
    },
    "product_category_translation": {
        "file": "product_category_name_translation.csv",
        "schema": [
            f("product_category_name", STR),
            f("product_category_name_english", STR),
        ],
    },
    "marketing_qualified_leads": {
        "file": "olist_marketing_qualified_leads_dataset.csv",
        "schema": [
            f("mql_id", STR, "REQUIRED"),
            f("first_contact_date", DATE),
            f("landing_page_id", STR),
            f("origin", STR),
        ],
    },
    "closed_deals": {
        "file": "olist_closed_deals_dataset.csv",
        "schema": [
            f("mql_id", STR, "REQUIRED"),
            f("seller_id", STR),
            f("sdr_id", STR),
            f("sr_id", STR),
            f("won_date", TS),
            f("business_segment", STR),
            f("lead_type", STR),
            f("lead_behaviour_profile", STR),
            f("has_company", STR),
            f("has_gtin", STR),
            f("average_stock", STR),
            f("business_type", STR),
            f("declared_product_catalog_size", FLT),
            f("declared_monthly_revenue", FLT),
        ],
    },
}