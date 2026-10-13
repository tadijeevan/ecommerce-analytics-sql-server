CREATE OR ALTER VIEW reporting.vw_monthly_revenue
AS
WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS RevenueMonth,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        COUNT(*) AS TotalOrderItems,
        SUM(oi.price) AS ProductRevenue,
        SUM(oi.freight_value) AS FreightRevenue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT
    RevenueMonth,
    TotalOrders,
    TotalOrderItems,
    CAST(ProductRevenue AS DECIMAL(18, 2)) AS ProductRevenue,
    CAST(FreightRevenue AS DECIMAL(18, 2)) AS FreightRevenue
FROM MonthlyRevenue;
GO