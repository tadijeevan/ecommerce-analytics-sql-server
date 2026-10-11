/*
    Project: E-commerce Analytics
    Dataset: Olist Sellers
    Purpose: Load raw seller data into the staging layer
*/

USE EcommerceAnalytics;
GO

-- Step 1: Create the staging table
IF OBJECT_ID('staging.sellers', 'U') IS NULL
BEGIN
    CREATE TABLE staging.sellers
    (
        seller_id                  VARCHAR(32) NOT NULL,
        seller_zip_code_prefix     VARCHAR(10) NOT NULL,
        seller_city                VARCHAR(100) NOT NULL,
        seller_state               CHAR(2) NOT NULL,

        CONSTRAINT PK_sellers
            PRIMARY KEY (seller_id)
    );
END;
GO

-- Step 2: Check that the raw table exists
IF OBJECT_ID('dbo.olist_sellers_dataset', 'U') IS NULL
BEGIN
    THROW 50001,
        'Raw sellers table dbo.olist_sellers_dataset does not exist.',
        1;
END;
GO

-- Step 3: Validate the raw data
SELECT
    COUNT(*) AS raw_row_count,
    COUNT(DISTINCT seller_id) AS distinct_seller_ids,
    SUM(
        CASE
            WHEN seller_id IS NULL
                 OR LTRIM(RTRIM(seller_id)) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_seller_ids
FROM dbo.olist_sellers_dataset;
GO

-- Step 4: Prevent accidental duplicate loading
IF EXISTS (SELECT 1 FROM staging.sellers)
BEGIN
    THROW 50002,
        'Staging sellers already contains data. Load cancelled to prevent duplicates.',
        1;
END;
GO

-- Step 5: Load the staging table
INSERT INTO staging.sellers
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    LTRIM(RTRIM(seller_id)),
    LTRIM(RTRIM(CONVERT(VARCHAR(10), seller_zip_code_prefix))),
    LTRIM(RTRIM(seller_city)),
    UPPER(LTRIM(RTRIM(seller_state)))
FROM dbo.olist_sellers_dataset;
GO

-- Step 6: Verify the staging load
SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_id) AS unique_sellers,
    COUNT(DISTINCT seller_state) AS unique_states,
    COUNT(DISTINCT seller_city) AS unique_cities,
    SUM(
        CASE
            WHEN seller_zip_code_prefix IS NULL
                 OR LTRIM(RTRIM(seller_zip_code_prefix)) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_postal_codes
FROM staging.sellers;
GO