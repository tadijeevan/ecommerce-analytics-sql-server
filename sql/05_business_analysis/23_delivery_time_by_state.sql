USE EcommerceAnalytics;
GO

/*
Analysis: Delivery Time by Customer State

Business questions:
1. What is the average delivery time for each customer state?
2. Which states have the shortest and longest average delivery times?
3. How many delivered orders are included in each state's calculation?

Metric definitions:
- ActualDeliveryDays:
    Number of calendar-day boundaries between purchase and delivery.
- AverageDeliveryDays:
    Average ActualDeliveryDays for eligible delivered orders.

Scope and limitations:
- Only delivered orders with valid purchase and delivery timestamps
  are included.
- States are based on the customer's registered state.
- Results describe the dataset and do not establish that geography
  alone causes differences in delivery performance.
*/

;WITH StateDeliveryDetails AS
(
    SELECT
        c.customer_state AS CustomerState,
        o.order_id AS OrderID,
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS ActualDeliveryDays
    FROM staging.orders AS o
    INNER JOIN staging.customers AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
),
StateDeliverySummary AS
(
    SELECT
        CustomerState,
        COUNT(DISTINCT OrderID) AS DeliveredOrders,
        CAST(
            AVG(CAST(ActualDeliveryDays AS DECIMAL(10, 2)))
            AS DECIMAL(10, 2)
        ) AS AverageDeliveryDays,
        MIN(ActualDeliveryDays) AS MinimumDeliveryDays,
        MAX(ActualDeliveryDays) AS MaximumDeliveryDays
    FROM StateDeliveryDetails
    GROUP BY CustomerState
)
SELECT
    CustomerState,
    DeliveredOrders,
    AverageDeliveryDays,
    MinimumDeliveryDays,
    MaximumDeliveryDays,
    DENSE_RANK() OVER (
        ORDER BY AverageDeliveryDays ASC
    ) AS FastestDeliveryRank,
    DENSE_RANK() OVER (
        ORDER BY AverageDeliveryDays DESC
    ) AS SlowestDeliveryRank
FROM StateDeliverySummary
ORDER BY AverageDeliveryDays ASC, DeliveredOrders DESC;
GO