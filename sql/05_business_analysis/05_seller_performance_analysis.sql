USE EcommerceAnalytics;
GO

/*
Analysis: Seller Performance

Business questions:
1. Which sellers generate the highest product revenue?
2. How many delivered orders does each seller receive?
3. How many delivered order items does each seller sell?
4. What is the average product revenue per delivered order?

Metric definitions:
- ProductRevenue: Sum of order item prices for delivered orders.
- TotalOrders: Count of distinct delivered orders per seller.
- TotalOrderItems: Count of delivered order items per seller.
- AverageRevenuePerOrder: Product revenue divided by distinct delivered orders.

Notes:
- Freight revenue is excluded.
- Only delivered orders are included.
- A seller may have multiple order items in one order.
*/

WITH SellerSummary AS
(
    SELECT
        oi.seller_id AS SellerID,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        COUNT(oi.order_item_id) AS TotalOrderItems,
        CAST(SUM(oi.price) AS DECIMAL(18, 2)) AS ProductRevenue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT TOP 10
    SellerID,
    TotalOrders,
    TotalOrderItems,
    ProductRevenue,
    CAST(
        ProductRevenue / NULLIF(TotalOrders, 0)
        AS DECIMAL(18, 2)
    ) AS AverageRevenuePerOrder
FROM SellerSummary
ORDER BY ProductRevenue DESC;
GO