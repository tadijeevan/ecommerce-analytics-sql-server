/*
Project: E-commerce Analytics Engineering with SQL Server
Purpose: Load and validate customer data
Source: dbo.olist_customers_dataset
Target: staging.customers
*/

USE EcommerceAnalytics;
GO

-- Load customers into the staging table.
-- Run this INSERT only once unless the target table is cleared first.

INSERT INTO staging.customers
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM dbo.olist_customers_dataset;
GO

-- Validate row counts and customer identifiers.

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT customer_id) AS DistinctCustomerIDs,
    COUNT(DISTINCT customer_unique_id) AS DistinctUniqueCustomerIDs
FROM staging.customers;
GO