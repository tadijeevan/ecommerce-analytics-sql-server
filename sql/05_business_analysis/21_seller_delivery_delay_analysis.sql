/*
Business Question 23:
Which sellers have the highest average delivery delay?

Methodology:
1. Include only delivered orders with valid actual and estimated
   delivery timestamps.
2. Create one record per seller per order.
3. Calculate delivery delay in calendar days:
      Positive = delivered late
      Zero     = delivered on the estimated date
      Negative = delivered early
4. Require at least 20 distinct delivered orders per seller.
5. Rank sellers by average delivery delay, highest first.

Important limitation:
Delivery timestamps are recorded at the order level, not the
seller level. If an order contains products from multiple sellers,
the same order-level delivery delay is attributed to each seller
associated with that order. Therefore, these results measure
seller-associated order delivery performance, not independently
measured seller-specific shipping time.
*/

;WITH SellerOrderDelivery AS
(
    SELECT DISTINCT
        oi.seller_id,
        o.order_id,
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date,
        DATEDIFF
        (
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) AS DeliveryDelayDays
    FROM staging.order_items AS oi
    INNER JOIN staging.orders AS o
        ON oi.order_id = o.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
),
SellerDeliveryPerformance AS
(
    SELECT
        sod.seller_id,
        s.seller_state,
        COUNT(*) AS DeliveredOrders,

        CAST(
            AVG(CAST(sod.DeliveryDelayDays AS DECIMAL(10, 2)))
            AS DECIMAL(10, 2)
        ) AS AvgDeliveryDelayDays,

        SUM(
            CASE
                WHEN sod.DeliveryDelayDays > 0 THEN 1
                ELSE 0
            END
        ) AS LateOrders,

        SUM(
            CASE
                WHEN sod.DeliveryDelayDays = 0 THEN 1
                ELSE 0
            END
        ) AS OnTimeOrders,

        SUM(
            CASE
                WHEN sod.DeliveryDelayDays < 0 THEN 1
                ELSE 0
            END
        ) AS EarlyOrders,

        CAST(
            100.0 * SUM(
                CASE
                    WHEN sod.DeliveryDelayDays > 0 THEN 1
                    ELSE 0
                END
            ) / COUNT(*)
            AS DECIMAL(5, 2)
        ) AS LateDeliveryPercentage

    FROM SellerOrderDelivery AS sod
    INNER JOIN staging.sellers AS s
        ON sod.seller_id = s.seller_id
    GROUP BY
        sod.seller_id,
        s.seller_state
)
SELECT
    seller_id,
    seller_state,
    DeliveredOrders,
    AvgDeliveryDelayDays,
    LateOrders,
    OnTimeOrders,
    EarlyOrders,
    LateDeliveryPercentage
FROM SellerDeliveryPerformance
WHERE DeliveredOrders >= 20
ORDER BY
    AvgDeliveryDelayDays DESC,
    DeliveredOrders DESC;