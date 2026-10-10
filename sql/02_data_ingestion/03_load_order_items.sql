/*
Project: E-commerce Analytics Engineering with SQL Server
File: 03_load_order_items.sql

Purpose:
Load order-item data from the raw import table
into the typed staging table.
*/

USE EcommerceAnalytics;
GO

-- Check raw source row count
SELECT COUNT(*) AS RawOrderItemRows
FROM dbo.olist_order_items_dataset;
GO

-- Load data into the staging table
INSERT INTO staging.order_items
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    order_id,
    TRY_CONVERT(INT, order_item_id),
    product_id,
    seller_id,
    TRY_CONVERT(DATETIME2(0), shipping_limit_date, 120),
    TRY_CONVERT(DECIMAL(10,2), price),
    TRY_CONVERT(DECIMAL(10,2), freight_value)
FROM dbo.olist_order_items_dataset;
GO

-- Validate the staging table
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT order_id) AS DistinctOrders,
    COUNT(DISTINCT product_id) AS DistinctProducts,
    SUM(price) AS TotalItemValue,
    SUM(freight_value) AS TotalFreightValue
FROM staging.order_items;
GO