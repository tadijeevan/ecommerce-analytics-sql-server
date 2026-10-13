CREATE OR ALTER VIEW reporting.vw_category_performance
AS
SELECT
    COALESCE(
        t.product_category_name_english,
        'unknown'
    ) AS ProductCategory,
    COUNT(DISTINCT oi.order_id) AS TotalOrders,
    COUNT(*) AS TotalOrderItems,
    CAST(SUM(oi.price) AS DECIMAL(18, 2)) AS ProductRevenue,
    CAST(SUM(oi.freight_value) AS DECIMAL(18, 2)) AS FreightRevenue
FROM staging.order_items AS oi
INNER JOIN staging.products AS p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
INNER JOIN staging.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    COALESCE(
        t.product_category_name_english,
        'unknown'
    );
GO
