/*
Analysis: Product Category Performance
Purpose:
    Compare product categories by orders, items sold,
    product revenue, and average item price.

Definitions:
    Only delivered orders are included.
    Product revenue excludes freight charges.
    Average item price is calculated across order items.
    Missing or untranslated categories are grouped as Unknown Category.
    Currency: Brazilian reais (BRL).
*/

USE EcommerceAnalytics;
GO

SELECT
    COALESCE(
        t.product_category_name_english,
        'Unknown Category'
    ) AS ProductCategory,
    COUNT(DISTINCT oi.order_id) AS TotalOrders,
    COUNT(*) AS TotalItemsSold,
    CAST(SUM(oi.price) AS DECIMAL(15, 2)) AS TotalProductRevenue,
    CAST(AVG(oi.price) AS DECIMAL(12, 2)) AS AverageItemPrice
FROM staging.order_items AS oi
INNER JOIN staging.orders AS o
    ON oi.order_id = o.order_id
INNER JOIN staging.products AS p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    COALESCE(
        t.product_category_name_english,
        'Unknown Category'
    )
ORDER BY TotalProductRevenue DESC;