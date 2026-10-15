USE EcommerceAnalytics;
GO

/*
Project: E-commerce Operations & Customer Analytics
Purpose: Core data-quality checks covering Questions 1-5.

Checks:
    Q1. Source row counts and distinct business entities
    Q2. Missing values in important columns
    Q3. Duplicate business keys
    Q4. Missing or inconsistent order timestamps
    Q5. Orphan order items, payments and reviews

Source tables:
    staging.orders
    staging.customers
    staging.order_items
    staging.order_payments
    staging.order_reviews
    staging.products
    staging.sellers
    staging.geolocation

Important:
    These checks report potential data-quality issues.
    Investigate before correcting or deleting any records.
*/

------------------------------------------------------------
-- Q1. SOURCE ROW COUNTS AND DISTINCT BUSINESS ENTITIES
------------------------------------------------------------

SELECT
    'orders' AS TableName,
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT order_id) AS DistinctBusinessEntities
FROM staging.orders

UNION ALL

SELECT
    'customers',
    COUNT_BIG(*),
    COUNT(DISTINCT customer_id)
FROM staging.customers

UNION ALL

SELECT
    'order_items',
    COUNT_BIG(*),
    COUNT(DISTINCT order_id)
FROM staging.order_items

UNION ALL

SELECT
    'order_payments',
    COUNT_BIG(*),
    COUNT(DISTINCT order_id)
FROM staging.order_payments

UNION ALL

SELECT
    'order_reviews',
    COUNT_BIG(*),
    COUNT(DISTINCT review_id)
FROM staging.order_reviews

UNION ALL

SELECT
    'products',
    COUNT_BIG(*),
    COUNT(DISTINCT product_id)
FROM staging.products

UNION ALL

SELECT
    'sellers',
    COUNT_BIG(*),
    COUNT(DISTINCT seller_id)
FROM staging.sellers

UNION ALL

SELECT
    'geolocation',
    COUNT_BIG(*),
    COUNT(DISTINCT geolocation_zip_code_prefix)
FROM staging.geolocation;

------------------------------------------------------------
-- Q2. MISSING VALUES IN IMPORTANT COLUMNS
------------------------------------------------------------

SELECT
    'orders' AS TableName,
    'order_approved_at' AS ColumnName,
    COUNT_BIG(*) AS MissingRows
FROM staging.orders
WHERE order_approved_at IS NULL

UNION ALL

SELECT 'orders', 'order_delivered_carrier_date', COUNT_BIG(*)
FROM staging.orders
WHERE order_delivered_carrier_date IS NULL

UNION ALL

SELECT 'orders', 'order_delivered_customer_date', COUNT_BIG(*)
FROM staging.orders
WHERE order_delivered_customer_date IS NULL

UNION ALL

SELECT 'order_reviews', 'review_comment_title', COUNT_BIG(*)
FROM staging.order_reviews
WHERE review_comment_title IS NULL

UNION ALL

SELECT 'order_reviews', 'review_comment_message', COUNT_BIG(*)
FROM staging.order_reviews
WHERE review_comment_message IS NULL

UNION ALL

SELECT 'products', 'product_category_name', COUNT_BIG(*)
FROM staging.products
WHERE product_category_name IS NULL

UNION ALL

SELECT 'products', 'product_weight_g', COUNT_BIG(*)
FROM staging.products
WHERE product_weight_g IS NULL

UNION ALL

SELECT 'products', 'product_length_cm', COUNT_BIG(*)
FROM staging.products
WHERE product_length_cm IS NULL

UNION ALL

SELECT 'products', 'product_height_cm', COUNT_BIG(*)
FROM staging.products
WHERE product_height_cm IS NULL

UNION ALL

SELECT 'products', 'product_width_cm', COUNT_BIG(*)
FROM staging.products
WHERE product_width_cm IS NULL

ORDER BY TableName, ColumnName;

------------------------------------------------------------
-- Q3. DUPLICATE BUSINESS KEYS
------------------------------------------------------------

-- Orders: order_id should be unique.

SELECT
    'orders' AS TableName,
    'order_id' AS BusinessKey,
    COUNT_BIG(*) AS DuplicateGroups
FROM (
    SELECT order_id
    FROM staging.orders
    GROUP BY order_id
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

-- Customers: customer_id should be unique.
-- customer_unique_id is deliberately not checked for uniqueness.

SELECT
    'customers',
    'customer_id',
    COUNT_BIG(*)
FROM (
    SELECT customer_id
    FROM staging.customers
    GROUP BY customer_id
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

-- Order items: order_id + order_item_id should be unique.

SELECT
    'order_items',
    'order_id + order_item_id',
    COUNT_BIG(*)
FROM (
    SELECT order_id, order_item_id
    FROM staging.order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

-- Payments: order_id + payment_sequential should be unique.

SELECT
    'order_payments',
    'order_id + payment_sequential',
    COUNT_BIG(*)
FROM (
    SELECT order_id, payment_sequential
    FROM staging.order_payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

-- Reviews: repeated review_id values require investigation.
-- Do not automatically treat them as invalid records.

SELECT
    'order_reviews',
    'review_id',
    COUNT_BIG(*)
FROM (
    SELECT review_id
    FROM staging.order_reviews
    GROUP BY review_id
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

SELECT
    'products',
    'product_id',
    COUNT_BIG(*)
FROM (
    SELECT product_id
    FROM staging.products
    GROUP BY product_id
    HAVING COUNT_BIG(*) > 1
) AS d

UNION ALL

SELECT
    'sellers',
    'seller_id',
    COUNT_BIG(*)
FROM (
    SELECT seller_id
    FROM staging.sellers
    GROUP BY seller_id
    HAVING COUNT_BIG(*) > 1
) AS d;

-- Geolocation: identify exact duplicate records across all five columns.
-- Repeated postal codes alone are not necessarily duplicates.
-- Report the issue; do not automatically delete source records.

SELECT
    COUNT_BIG(*) AS DuplicateGroups,
    SUM(Occurrences - 1) AS ExcessDuplicateRows,
    MAX(Occurrences) AS MaximumOccurrences
FROM (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        COUNT_BIG(*) AS Occurrences
    FROM staging.geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT_BIG(*) > 1
) AS DuplicateGeolocation;

------------------------------------------------------------
-- Q4. MISSING OR INCONSISTENT ORDER TIMESTAMPS
------------------------------------------------------------

-- Missing timestamp counts.

SELECT
    COUNT_BIG(*) AS TotalOrders,
    SUM(CASE WHEN order_purchase_timestamp IS NULL
             THEN 1 ELSE 0 END) AS MissingPurchaseTimestamp,
    SUM(CASE WHEN order_approved_at IS NULL
             THEN 1 ELSE 0 END) AS MissingApprovalTimestamp,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL
             THEN 1 ELSE 0 END) AS MissingCarrierTimestamp,
    SUM(CASE WHEN order_delivered_customer_date IS NULL
             THEN 1 ELSE 0 END) AS MissingCustomerDeliveryTimestamp,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL
             THEN 1 ELSE 0 END) AS MissingEstimatedDeliveryTimestamp
FROM staging.orders;

-- Timestamp inconsistencies.
-- The categories may overlap; do not add their counts together.

SELECT
    SUM(
        CASE
            WHEN order_approved_at IS NOT NULL
             AND order_purchase_timestamp IS NOT NULL
             AND order_approved_at < order_purchase_timestamp
            THEN 1 ELSE 0
        END
    ) AS ApprovalBeforePurchase,

    SUM(
        CASE
            WHEN order_delivered_carrier_date IS NOT NULL
             AND order_approved_at IS NOT NULL
             AND order_delivered_carrier_date < order_approved_at
            THEN 1 ELSE 0
        END
    ) AS CarrierBeforeApproval,

    SUM(
        CASE
            WHEN order_delivered_customer_date IS NOT NULL
             AND order_delivered_carrier_date IS NOT NULL
             AND order_delivered_customer_date < order_delivered_carrier_date
            THEN 1 ELSE 0
        END
    ) AS CustomerDeliveryBeforeCarrier,

    SUM(
        CASE
            WHEN order_delivered_customer_date IS NOT NULL
             AND order_purchase_timestamp IS NOT NULL
             AND order_delivered_customer_date < order_purchase_timestamp
            THEN 1 ELSE 0
        END
    ) AS CustomerDeliveryBeforePurchase
FROM staging.orders;

-- Delivered orders missing an actual delivery timestamp.

SELECT
    order_status,
    COUNT_BIG(*) AS OrdersMissingCustomerDeliveryTimestamp
FROM staging.orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NULL
GROUP BY order_status;

------------------------------------------------------------
-- Q5. ORPHAN CHILD RECORDS
------------------------------------------------------------

-- Order items without a matching parent order.

SELECT
    'order_items' AS ChildTable,
    COUNT_BIG(*) AS OrphanRows
FROM staging.order_items AS oi
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.orders AS o
    WHERE o.order_id = oi.order_id
)

UNION ALL

-- Payments without a matching parent order.

SELECT
    'order_payments',
    COUNT_BIG(*)
FROM staging.order_payments AS op
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.orders AS o
    WHERE o.order_id = op.order_id
)

UNION ALL

-- Reviews without a matching parent order.

SELECT
    'order_reviews',
    COUNT_BIG(*)
FROM staging.order_reviews AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.orders AS o
    WHERE o.order_id = r.order_id
);