USE EcommerceAnalytics;
GO

/*
Analysis: Order Status, Cancellation, and Unavailable Orders

Business questions:
1. How many orders exist in each order status?
2. What percentage of all orders does each status represent?
3. What is the order cancellation rate?
4. What percentage of orders are unavailable?
5. How many orders have not reached the delivered status?

Metric definitions:
- TotalOrders:
    Number of distinct orders in each status.

- StatusPercentage:
    Percentage of all orders represented by each status.

- CancellationRatePercentage:
    Canceled orders divided by all orders, multiplied by 100.

- UnavailableOrderPercentage:
    Unavailable orders divided by all orders, multiplied by 100.

- OrdersNotDelivered:
    Orders whose status is not delivered.

Notes:
- All order statuses present in the source data are included.
- Cancellation and unavailable-order percentages use all orders
  as the denominator.
- Orders that are not delivered are not necessarily canceled
  or unavailable; they may have other statuses.
*/

------------------------------------------------------------
-- 1. Order status distribution
------------------------------------------------------------

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

------------------------------------------------------------
-- 2. Overall order status and cancellation summary
------------------------------------------------------------

SELECT
    COUNT(DISTINCT order_id) AS TotalOrders,

    COUNT(DISTINCT CASE
        WHEN order_status = 'delivered'
        THEN order_id
    END) AS DeliveredOrders,

    COUNT(DISTINCT CASE
        WHEN order_status = 'canceled'
        THEN order_id
    END) AS CanceledOrders,

    COUNT(DISTINCT CASE
        WHEN order_status = 'unavailable'
        THEN order_id
    END) AS UnavailableOrders,

    COUNT(DISTINCT CASE
        WHEN order_status <> 'delivered'
        THEN order_id
    END) AS OrdersNotDelivered,

    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'canceled'
            THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(5, 2)
    ) AS CancellationRatePercentage,

    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'unavailable'
            THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(5, 2)
    ) AS UnavailableOrderPercentage,

    CAST(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END)
        / NULLIF(COUNT(DISTINCT order_id), 0)
        AS DECIMAL(5, 2)
    ) AS DeliveredOrderPercentage

FROM staging.orders;
GO