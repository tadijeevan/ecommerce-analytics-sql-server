USE EcommerceAnalytics;
GO

/*
Analysis: Top Product Categories by Revenue

Business question:
Which product categories generate the highest product revenue?

Metric definition:
ProductRevenue = SUM of order item prices for delivered orders.

Notes:
- Freight revenue is excluded.
- Only delivered orders are included.
- Products without a category or English translation are excluded.
*/

SELECT TOP 10
    t.product_category_name_english AS ProductCategory,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(oi.order_item_id) AS TotalOrderItems,
    CAST(SUM(oi.price) AS DECIMAL(18, 2)) AS ProductRevenue
FROM staging.orders AS o
INNER JOIN staging.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN staging.products AS p
    ON oi.product_id = p.product_id
INNER JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY
    t.product_category_name_english
ORDER BY
    SUM(oi.price) DESC;
GO