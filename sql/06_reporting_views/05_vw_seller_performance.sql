CREATE OR ALTER VIEW reporting.vw_seller_performance
AS
SELECT
    oi.seller_id AS SellerID,
    COUNT(DISTINCT oi.order_id) AS TotalOrders,
    COUNT(*) AS TotalItemsSold,
    CAST(SUM(oi.price) AS DECIMAL(18, 2)) AS ProductRevenue,
    CAST(SUM(oi.freight_value) AS DECIMAL(18, 2)) AS FreightRevenue
FROM staging.order_items AS oi
INNER JOIN staging.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    oi.seller_id;
GO