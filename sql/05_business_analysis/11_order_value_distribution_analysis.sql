/*
Analysis: Order Value Distribution
Purpose:
    Analyze delivered order values and their distribution across value bands.

Definitions:
    Product revenue = sum of item prices.
    Freight charges = sum of item freight values.
    Total order value = product revenue + freight charges.
    Only delivered orders are included.
    Currency: Brazilian reais (BRL).
*/

USE EcommerceAnalytics;
GO

-- 1. Summary metrics for delivered orders

WITH OrderValues AS
(
    SELECT
        o.order_id,
        SUM(oi.price) AS ProductRevenue,
        SUM(oi.freight_value) AS FreightCharges,
        SUM(oi.price) + SUM(oi.freight_value) AS TotalOrderValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS TotalDeliveredOrders,
    CAST(AVG(TotalOrderValue) AS DECIMAL(12, 2)) AS AverageOrderValue,
    CAST(MIN(TotalOrderValue) AS DECIMAL(12, 2)) AS MinimumOrderValue,
    CAST(MAX(TotalOrderValue) AS DECIMAL(12, 2)) AS MaximumOrderValue,
    CAST(AVG(ProductRevenue) AS DECIMAL(12, 2)) AS AverageProductRevenue,
    CAST(AVG(FreightCharges) AS DECIMAL(12, 2)) AS AverageFreightCharges
FROM OrderValues;
GO

-- 2. Distribution of delivered orders by value band

WITH OrderValues AS
(
    SELECT
        o.order_id,
        SUM(oi.price) + SUM(oi.freight_value) AS TotalOrderValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
),
OrderBands AS
(
    SELECT
        CASE
            WHEN TotalOrderValue < 100 THEN 'Under R$100'
            WHEN TotalOrderValue < 250 THEN 'R$100 to R$249.99'
            WHEN TotalOrderValue < 500 THEN 'R$250 to R$499.99'
            ELSE 'R$500 and above'
        END AS OrderValueBand,
        CASE
            WHEN TotalOrderValue < 100 THEN 1
            WHEN TotalOrderValue < 250 THEN 2
            WHEN TotalOrderValue < 500 THEN 3
            ELSE 4
        END AS SortOrder
    FROM OrderValues
)
SELECT
    OrderValueBand,
    COUNT(*) AS NumberOfOrders,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS OrderPercentage
FROM OrderBands
GROUP BY OrderValueBand, SortOrder
ORDER BY SortOrder;