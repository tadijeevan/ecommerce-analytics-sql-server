USE EcommerceAnalytics;
GO

/*
Purpose:
    Rank product categories by monthly item value.

Business question:
    Which product categories perform best each month?

Metrics:
    - Monthly item value
    - Monthly category rank
    - Number of orders
    - Number of items sold

Methodology:
    1. Include delivered orders only.
    2. Aggregate item value by month and product category.
    3. Rank categories within each month using DENSE_RANK().
    4. Rank 1 represents the highest monthly item value.

Sources:
    staging.orders
    staging.order_items
    staging.products
    dbo.product_category_name_translation

Note:
    Item value excludes freight.
    Missing category translations are labeled 'Unknown Category'.
    Rankings use item value, not profit or total order payment.
*/

WITH MonthlyCategoryPerformance AS (
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS OrderMonth,

        COALESCE(
            t.product_category_name_english,
            'Unknown Category'
        ) AS ProductCategory,

        COUNT(DISTINCT o.order_id) AS NumberOfOrders,

        COUNT_BIG(*) AS NumberOfItems,

        SUM(oi.price) AS MonthlyItemValue

    FROM staging.orders AS o

    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN staging.products AS p
        ON oi.product_id = p.product_id

    LEFT JOIN dbo.product_category_name_translation AS t
        ON p.product_category_name = t.product_category_name

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ),
        COALESCE(
            t.product_category_name_english,
            'Unknown Category'
        )
),

MonthlyCategoryRanking AS (
    SELECT
        OrderMonth,
        ProductCategory,
        NumberOfOrders,
        NumberOfItems,
        MonthlyItemValue,

        DENSE_RANK() OVER (
            PARTITION BY OrderMonth
            ORDER BY MonthlyItemValue DESC
        ) AS CategoryRank

    FROM MonthlyCategoryPerformance
)

SELECT
    OrderMonth,
    ProductCategory,
    NumberOfOrders,
    NumberOfItems,
    CAST(MonthlyItemValue AS DECIMAL(18, 2)) AS MonthlyItemValue,
    CategoryRank

FROM MonthlyCategoryRanking

ORDER BY
    OrderMonth,
    CategoryRank,
    ProductCategory;