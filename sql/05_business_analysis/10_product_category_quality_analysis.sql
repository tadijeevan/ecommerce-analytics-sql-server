/*
Analysis: Product Category Data Quality
Purpose:
    Measure product category completeness and English translation coverage.

Metrics:
    Total products
    Products without a category
    Products with a category but no English translation
    Products with a translated category
*/

USE EcommerceAnalytics;
GO

SELECT
    COUNT(*) AS TotalProducts,
    SUM(
        CASE
            WHEN p.product_category_name IS NULL
                OR LTRIM(RTRIM(p.product_category_name)) = ''
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithoutCategory,
    SUM(
        CASE
            WHEN p.product_category_name IS NOT NULL
                AND LTRIM(RTRIM(p.product_category_name)) <> ''
                AND t.product_category_name_english IS NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithoutEnglishTranslation,
    SUM(
        CASE
            WHEN p.product_category_name IS NOT NULL
                AND LTRIM(RTRIM(p.product_category_name)) <> ''
                AND t.product_category_name_english IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithTranslatedCategory
FROM staging.products AS p
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name;