USE EcommerceAnalytics;
GO

/*
Analysis: Seller Performance by Geography

Business question:
    How does seller performance vary by geography?

Metrics:
    - Number of sellers
    - Number of delivered orders
    - Number of delivered order items
    - Total item value
    - Average item value per delivered order

Methodology:
    1. Include delivered orders only.
    2. Aggregate item value and order counts by seller.
    3. Join seller performance with seller geography.
    4. Summarize performance by state.

Definitions:
    Item value excludes freight.
    Only delivered orders are included.
    Item value is not profit or accounting revenue.
*/

WITH SellerPerformance AS
(
    SELECT
        oi.seller_id AS SellerID,
        COUNT(DISTINCT o.order_id) AS DeliveredOrders,
        COUNT_BIG(*) AS DeliveredOrderItems,
        SUM(oi.price) AS TotalItemValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    s.seller_state AS SellerState,
    COUNT(DISTINCT s.seller_id) AS NumberOfSellers,
    SUM(COALESCE(sp.DeliveredOrders, 0)) AS DeliveredOrders,
    SUM(COALESCE(sp.DeliveredOrderItems, 0)) AS DeliveredOrderItems,
    CAST(
        SUM(COALESCE(sp.TotalItemValue, 0))
        AS DECIMAL(18, 2)
    ) AS TotalItemValue,
    CAST(
        SUM(COALESCE(sp.TotalItemValue, 0))
        / NULLIF(SUM(COALESCE(sp.DeliveredOrders, 0)), 0)
        AS DECIMAL(18, 2)
    ) AS AverageItemValuePerDeliveredOrder
FROM staging.sellers AS s
LEFT JOIN SellerPerformance AS sp
    ON s.seller_id = sp.SellerID
GROUP BY s.seller_state
ORDER BY TotalItemValue DESC;