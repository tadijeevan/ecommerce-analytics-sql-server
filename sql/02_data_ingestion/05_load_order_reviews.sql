/*
Project: E-Commerce Analytics using SQL Server
Dataset: Olist Order Reviews
Purpose: Load and validate order reviews
*/

USE EcommerceAnalytics;
GO

-- 1. Check raw data volume
SELECT COUNT(*) AS Raw_Review_Rows
FROM dbo.olist_order_reviews_dataset;
GO

-- 2. Load reviews into staging
-- Initial load only: run against an empty staging table.

INSERT INTO staging.order_reviews
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    LTRIM(RTRIM(review_id)),
    LTRIM(RTRIM(order_id)),
    TRY_CONVERT(INT, review_score),
    NULLIF(LTRIM(RTRIM(review_comment_title)), ''),
    NULLIF(LTRIM(RTRIM(review_comment_message)), ''),
    TRY_CONVERT(DATETIME2(0), review_creation_date),
    TRY_CONVERT(
        DATETIME2(0),
        NULLIF(LTRIM(RTRIM(review_answer_timestamp)), '')
    )
FROM dbo.olist_order_reviews_dataset;
GO

-- 3. Validate staging row count
SELECT COUNT(*) AS Staging_Review_Rows
FROM staging.order_reviews;
GO
