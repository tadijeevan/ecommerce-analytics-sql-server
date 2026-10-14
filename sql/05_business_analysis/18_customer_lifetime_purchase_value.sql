USE EcommerceAnalytics;
GO

/*
Analysis: Customer Lifetime Purchase Value

Business question:
    Which customers have the highest observed lifetime purchase value?

Methodology:
    1. Identify customers using customer_unique_id.
    2. Include delivered orders only.
    3. Calculate item value from order_items.price.
    4. Aggregate item value by customer.
    5. Rank customers by observed lifetime item value.

Definitions:
    - Item value excludes freight.
    - Only delivered orders are included.
    - Customer value represents observed item value in this dataset,
      not profit or accounting revenue.
*/

WITH CustomerItemValue AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS DeliveredOrderCount,
        COUNT_BIG(*) AS TotalItemsPurchased,
        SUM(oi.price) AS LifetimeItemValue
    FROM staging.customers AS c
    INNER JOIN staging.orders AS o
        ON c.customer_id = o.customer_id
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        c.customer_unique_id
),
RankedCustomers AS
(
    SELECT
        customer_unique_id,
        DeliveredOrderCount,
        TotalItemsPurchased,
        LifetimeItemValue,
        DENSE_RANK() OVER (
            ORDER BY LifetimeItemValue DESC
        ) AS CustomerValueRank
    FROM CustomerItemValue
)
SELECT TOP (100)
    CustomerValueRank,
    customer_unique_id,
    DeliveredOrderCount,
    TotalItemsPurchased,
    CAST(LifetimeItemValue AS DECIMAL(18, 2))
        AS LifetimeItemValue
FROM RankedCustomers
ORDER BY
    CustomerValueRank,
    customer_unique_id;