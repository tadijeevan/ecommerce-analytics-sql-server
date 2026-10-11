/*
    Project: E-commerce Analytics
    Dataset: Olist Products
    Purpose: Load raw product data into the staging layer
*/

-- Step 1: Create the staging table
IF OBJECT_ID('staging.products', 'U') IS NULL
BEGIN
    CREATE TABLE staging.products
    (
        product_id                  VARCHAR(32) NOT NULL,
        product_category_name       VARCHAR(100) NULL,
        product_name_lenght         INT NULL,
        product_description_lenght  INT NULL,
        product_photos_qty          INT NULL,
        product_weight_g            INT NULL,
        product_length_cm            INT NULL,
        product_height_cm            INT NULL,
        product_width_cm             INT NULL,

        CONSTRAINT PK_products
            PRIMARY KEY (product_id)
    );
END;
GO

-- Step 2: Check the raw table exists
IF OBJECT_ID('dbo.olist_products_dataset', 'U') IS NULL
BEGIN
    THROW 50001,
        'Raw products table dbo.olist_products_dataset does not exist.',
        1;
END;
GO

-- Step 3: Validate raw product IDs
SELECT
    COUNT(*) AS raw_row_count,
    COUNT(DISTINCT product_id) AS distinct_product_ids,
    SUM(CASE
            WHEN product_id IS NULL OR LTRIM(RTRIM(product_id)) = ''
            THEN 1 ELSE 0
        END) AS missing_product_ids
FROM dbo.olist_products_dataset;
GO

-- Step 4: Load the staging table
-- Initial load only: do not rerun after successful insertion.
IF EXISTS (SELECT 1 FROM staging.products)
BEGIN
    THROW 50002,
        'Staging products already contains data. Load cancelled to prevent duplicates.',
        1;
END;

INSERT INTO staging.products
(
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    LTRIM(RTRIM(product_id)),
    NULLIF(LTRIM(RTRIM(product_category_name)), ''),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_name_lenght)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_description_lenght)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_photos_qty)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_weight_g)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_length_cm)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_height_cm)), '')),
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(product_width_cm)), ''))
FROM dbo.olist_products_dataset;

GO

-- Step 5: Verify the staging load
SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)
        AS missing_categories,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END)
        AS missing_weights,
    SUM(CASE
            WHEN product_length_cm IS NULL
              OR product_height_cm IS NULL
              OR product_width_cm IS NULL
            THEN 1 ELSE 0
        END) AS products_missing_dimensions
FROM staging.products;
GO