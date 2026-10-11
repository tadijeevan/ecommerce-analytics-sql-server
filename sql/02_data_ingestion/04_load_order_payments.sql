/*
Project: E-commerce Analytics Engineering with SQL Server
File: 04_load_order_payments.sql

Purpose:
Load payment data from the raw import table
into the typed staging table.
*/

USE EcommerceAnalytics;
GO

-- Check raw source row count
SELECT COUNT(*) AS RawPaymentRows
FROM dbo.olist_order_payments_dataset;
GO

-- Load data into the staging table
INSERT INTO staging.order_payments
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    TRY_CONVERT(INT, payment_sequential),
    payment_type,
    TRY_CONVERT(INT, payment_installments),
    TRY_CONVERT(DECIMAL(10,2), payment_value)
FROM dbo.olist_order_payments_dataset;
GO

-- Validate the staging table
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT order_id) AS DistinctOrders,
    COUNT(DISTINCT payment_type) AS PaymentTypes,
    SUM(payment_value) AS TotalPaymentValue,
    SUM(CASE
        WHEN payment_value = 0 THEN 1
        ELSE 0
    END) AS ZeroValuePayments
FROM staging.order_payments;
GO