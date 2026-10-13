/*
Analysis: Customer Order Behavior
Purpose:
    Classify customers as one-time or repeat customers.
    Calculate customer counts, order counts, and customer percentages.

Definitions:
    Customer identity is based on customer_unique_id.
    All order statuses are included.
*/

USE EcommerceAnalytics;
GO

WITH CustomerOrderCounts AS
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS TotalOrders
    FROM staging.orders AS o
    INNER JOIN staging.customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_unique_id
)
SELECT
    CASE
        WHEN TotalOrders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS CustomerType,
    COUNT(*) AS NumberOfCustomers,
    SUM(TotalOrders) AS TotalOrders,
    CAST(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS CustomerPercentage
FROM CustomerOrderCounts
GROUP BY
    CASE
        WHEN TotalOrders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY
    NumberOfCustomers DESC;