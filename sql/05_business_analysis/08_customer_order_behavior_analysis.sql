USE EcommerceAnalytics;
GO

/*
Analysis: Customer Order Behavior and Repeat Purchase Rate

Business questions:
1. How many customers are one-time versus repeat customers?
2. What percentage of customers make repeat purchases?
3. How many orders are associated with each customer group?
4. What is the overall repeat purchase rate?

Metric definitions:
- Customer identity is based on customer_unique_id.
- One-time customer: A customer associated with exactly one order.
- Repeat customer: A customer associated with more than one order.
- RepeatPurchaseRate:
    Number of repeat customers divided by all identified customers,
    multiplied by 100.

Scope:
- All order statuses are included.
- Customer counts are based on customer_unique_id.
*/

------------------------------------------------------------
-- 1. Classify customers by order count
------------------------------------------------------------

;WITH CustomerOrderCounts AS
(
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS TotalOrders
    FROM staging.orders AS o
    INNER JOIN staging.customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY
        c.customer_unique_id
),
CustomerClassification AS
(
    SELECT
        customer_unique_id,
        TotalOrders,
        CASE
            WHEN TotalOrders = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS CustomerType
    FROM CustomerOrderCounts
)
SELECT
    CustomerType,
    COUNT(*) AS NumberOfCustomers,
    SUM(TotalOrders) AS TotalOrders,

    CAST(
        100.0 * COUNT(*)
        / NULLIF(SUM(COUNT(*)) OVER (), 0)
        AS DECIMAL(5, 2)
    ) AS CustomerPercentage

FROM CustomerClassification
GROUP BY CustomerType
ORDER BY NumberOfCustomers DESC;
GO

------------------------------------------------------------
-- 2. Overall repeat purchase rate
------------------------------------------------------------

;WITH CustomerOrderCounts AS
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
    COUNT(*) AS TotalCustomers,

    SUM(
        CASE
            WHEN TotalOrders = 1 THEN 1
            ELSE 0
        END
    ) AS OneTimeCustomers,

    SUM(
        CASE
            WHEN TotalOrders > 1 THEN 1
            ELSE 0
        END
    ) AS RepeatCustomers,

    CAST(
        100.0 * SUM(
            CASE
                WHEN TotalOrders > 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS RepeatPurchaseRatePercentage,

    SUM(TotalOrders) AS TotalOrders

FROM CustomerOrderCounts;
GO