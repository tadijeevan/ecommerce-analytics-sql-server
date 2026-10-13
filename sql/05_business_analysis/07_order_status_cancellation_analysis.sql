USE EcommerceAnalytics;
GO

/*
Analysis: Order Status and Cancellation

Business questions:
1. How many orders exist in each order status?
2. What percentage of all orders does each status represent?
3. What is the order cancellation rate?
4. How many orders have not reached the delivered status?

Metric definitions:
- TotalOrders: Number of distinct orders in each status.
- StatusPercentage: Percentage of all orders represented by each status.
- CancellationRate: Canceled orders divided by all orders.

Notes:
- All order statuses present in the source data are included.
- Cancellation rate uses all orders as the denominator.
- Orders that are not delivered are not necessarily canceled;
  they may have other statuses, such as shipped or processing.
*/

WITH OrderStatusSummary AS
(
    SELECT
        order_status AS OrderStatus,
        COUNT(DISTINCT order_id) AS TotalOrders
    FROM staging.orders
    GROUP BY order_status
),
StatusDistribution AS
(
    SELECT
        OrderStatus,
        TotalOrders,
        CAST(
            100.0 * TotalOrders
            / NULLIF(SUM(TotalOrders) OVER (), 0)
            AS DECIMAL(5, 2)
        ) AS StatusPercentage
    FROM OrderStatusSummary
)
SELECT
    OrderStatus,
    TotalOrders,
    StatusPercentage
FROM StatusDistribution
ORDER BY TotalOrders DESC;
GO

-- Overall order status and cancellation summary
SELECT
    COUNT(DISTINCT order_id) AS TotalOrders,
    COUNT(DISTINCT CASE
        WHEN order_status = 'delivered' THEN order_id
    END) AS DeliveredOrders,
    COUNT(DISTINCT CASE
        WHEN order_status = 'canceled' THEN order_id
    END) AS CanceledOrders,
    COUNT(DISTINCT CASE
        WHEN order_status <> 'delivered' THEN order_id
    END) AS OrdersNotDelivered,
    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'canceled' THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(5, 2)
    ) AS CancellationRatePercentage,
    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'delivered' THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(5, 2)
    ) AS DeliveredOrderPercentage
FROM staging.orders;
GO