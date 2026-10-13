USE EcommerceAnalytics;
GO

-- 1. Check the number of product category translations
SELECT COUNT(*) AS TotalRows
FROM dbo.product_category_name_translation;
GO

-- 2. Preview available category translations
SELECT TOP 10
    product_category_name,
    product_category_name_english
FROM dbo.product_category_name_translation
ORDER BY product_category_name;
GO

-- 3. Validate product category translation coverage
SELECT
    COUNT(*) AS TotalProducts,
    COUNT(p.product_category_name) AS ProductsWithCategory,
    COUNT(t.product_category_name_english)
        AS ProductsWithEnglishTranslation,
    SUM(
        CASE
            WHEN p.product_category_name IS NOT NULL
                 AND t.product_category_name_english IS NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithMissingTranslation
FROM staging.products AS p
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name;
GO

-- 4. Identify categories without a translation
SELECT
    p.product_category_name,
    COUNT(*) AS ProductCount
FROM staging.products AS p
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY ProductCount DESC;
GO

-- 5. Verify the manually added category mappings
SELECT
    product_category_name,
    product_category_name_english
FROM dbo.product_category_name_translation
WHERE product_category_name IN
(
    'portateis_cozinha_e_preparadores_de_alimentos',
    'pc_gamer'
);
GO