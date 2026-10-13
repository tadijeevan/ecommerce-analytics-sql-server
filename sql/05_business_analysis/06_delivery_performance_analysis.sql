USE EcommerceAnalytics;
GO

/*
Analysis: Order Delivery Performance

Business questions:
1. How many days does delivery take on average?
2. What percentage of delivered orders arrive late?
3. How many orders arrive early, on the estimated date, or late?

Metric definitions:
- ActualDeliveryDays: Days between purchase and actual delivery.
- EstimatedDeliveryDays: Days between purchase and estimated delivery.
- DeliveryVarianceDays: Actual delivery date minus estimated delivery date.
- Early: Delivered before the estimated date.
- OnTime: Delivered on the estimated date.
- Late: Delivered after the estimated date.

Notes:
- Only delivered orders with valid actual and estimated delivery dates
  are included.
- Delivery variance greater than zero means late delivery.
- Delivery variance less than zero means early delivery.
*/

WITH DeliveryDetails AS
(
    SELECT
        order_id,
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) AS ActualDeliveryDays,
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_estimated_delivery_date
        ) AS EstimatedDeliveryDays,
        DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) AS DeliveryVarianceDays
    FROM staging.orders
    WHERE order_status = 'delivered'
      AND order_purchase_timestamp IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
),
DeliverySummary AS
(
    SELECT
        COUNT(*) AS TotalDeliveredOrders,
        AVG(CAST(ActualDeliveryDays AS DECIMAL(10, 2)))
            AS AverageActualDeliveryDays,
        AVG(CAST(EstimatedDeliveryDays AS DECIMAL(10, 2)))
            AS AverageEstimatedDeliveryDays,
        SUM(CASE WHEN DeliveryVarianceDays < 0 THEN 1 ELSE 0 END)
            AS EarlyOrders,
        SUM(CASE WHEN DeliveryVarianceDays = 0 THEN 1 ELSE 0 END)
            AS OnTimeOrders,
        SUM(CASE WHEN DeliveryVarianceDays > 0 THEN 1 ELSE 0 END)
            AS LateOrders
    FROM DeliveryDetails
)
SELECT
    TotalDeliveredOrders,
    CAST(AverageActualDeliveryDays AS DECIMAL(10, 2))
        AS AverageActualDeliveryDays,
    CAST(AverageEstimatedDeliveryDays AS DECIMAL(10, 2))
        AS AverageEstimatedDeliveryDays,
    EarlyOrders,
    OnTimeOrders,
    LateOrders,
    CAST(
        100.0 * EarlyOrders / NULLIF(TotalDeliveredOrders, 0)
        AS DECIMAL(5, 2)
    ) AS EarlyDeliveryPercentage,
    CAST(
        100.0 * OnTimeOrders / NULLIF(TotalDeliveredOrders, 0)
        AS DECIMAL(5, 2)
    ) AS OnTimeDeliveryPercentage,
    CAST(
        100.0 * LateOrders / NULLIF(TotalDeliveredOrders, 0)
        AS DECIMAL(5, 2)
    ) AS LateDeliveryPercentage
FROM DeliverySummary;
GO