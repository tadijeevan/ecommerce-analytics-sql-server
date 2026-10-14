USE EcommerceAnalytics;
GO

/*
Analysis: Customer Order Value by Geographic Region

Business question:
    How does customer order value vary by geographic region?

Metrics:
    - Number of identifiable customers
    - Number of delivered orders
    - Total item value
    - Total freight value
    - Average item value per order
    - Average total order value, including freight

Methodology:
    1. Include delivered orders with a purchase timestamp.
    2. Aggregate item value and freight at the order level.
    3. Associate each order with the customer's state.
    4. Aggregate the results by state.
    5. Calculate average values per delivered order.

Definitions:
    Item value excludes freight.
    Total order value includes item value and freight.
    These metrics are not measures of profit or accounting revenue.
    Customer counts use customer_unique_id.
*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.price) AS ItemValue,
        SUM(oi.freight_value) AS FreightValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        o.order_id,
        o.customer_id
),
RegionalOrderValues AS
(
    SELECT
        c.customer_unique_id,
        c.customer_state,
        ov.order_id,
        ov.ItemValue,
        ov.FreightValue,
        ov.ItemValue + ov.FreightValue AS TotalOrderValue
    FROM OrderValues AS ov
    INNER JOIN staging.customers AS c
        ON ov.customer_id = c.customer_id
)
SELECT
    customer_state AS CustomerState,
    COUNT(DISTINCT customer_unique_id) AS UniqueCustomers,
    COUNT(DISTINCT order_id) AS DeliveredOrders,
    CAST(SUM(ItemValue) AS DECIMAL(18, 2)) AS TotalItemValue,
    CAST(SUM(FreightValue) AS DECIMAL(18, 2)) AS TotalFreightValue,
    CAST(AVG(ItemValue) AS DECIMAL(18, 2)) AS AverageItemValuePerOrder,
    CAST(AVG(TotalOrderValue) AS DECIMAL(18, 2)) AS AverageTotalOrderValue
FROM RegionalOrderValues
GROUP BY
    customer_state
ORDER BY
    AverageTotalOrderValue DESC;