/*
Project: E-commerce Analytics Engineering with SQL Server
File: 01_load_orders.sql

Purpose:
Load raw order data into the typed staging table.

Safety:
- Stops if staging.orders already contains records.
- Loads within a transaction.
- Validates source and loaded row counts.
*/

USE EcommerceAnalytics;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- 1. Validate source and target tables
------------------------------------------------------------

IF OBJECT_ID('dbo.olist_orders_dataset', 'U') IS NULL
BEGIN
    THROW 50001,
          'Raw source table dbo.olist_orders_dataset does not exist.',
          1;
END;

IF OBJECT_ID('staging.orders', 'U') IS NULL
BEGIN
    THROW 50002,
          'Target table staging.orders does not exist.',
          1;
END;

------------------------------------------------------------
-- 2. Check source and target row counts
------------------------------------------------------------

DECLARE @SourceRows BIGINT;
DECLARE @TargetRows BIGINT;
DECLARE @LoadedRows BIGINT;

SELECT @SourceRows = COUNT_BIG(*)
FROM dbo.olist_orders_dataset;

SELECT @TargetRows = COUNT_BIG(*)
FROM staging.orders;

SELECT
    @SourceRows AS RawOrderRows,
    @TargetRows AS ExistingStagingRows;

------------------------------------------------------------
-- 3. Stop if staging already contains data
------------------------------------------------------------

IF @TargetRows > 0
BEGIN
    THROW 50003,
          'staging.orders already contains data. Loading cancelled to prevent duplicates.',
          1;
END;

------------------------------------------------------------
-- 4. Load orders transactionally
------------------------------------------------------------

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO staging.orders
    (
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    )
    SELECT
        order_id,
        customer_id,
        order_status,
        TRY_CONVERT(DATETIME2(0), order_purchase_timestamp, 120),
        TRY_CONVERT(DATETIME2(0), order_approved_at, 120),
        TRY_CONVERT(DATETIME2(0), order_delivered_carrier_date, 120),
        TRY_CONVERT(DATETIME2(0), order_delivered_customer_date, 120),
        TRY_CONVERT(DATETIME2(0), order_estimated_delivery_date, 120)
    FROM dbo.olist_orders_dataset;

    SET @LoadedRows = @@ROWCOUNT;

    IF @LoadedRows <> @SourceRows
    BEGIN
        THROW 50004,
              'Loaded row count does not match source row count.',
              1;
    END;

    COMMIT TRANSACTION;

    SELECT
        @SourceRows AS RawOrderRows,
        @LoadedRows AS LoadedRows,
        'Load completed successfully' AS LoadStatus;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;

------------------------------------------------------------
-- 5. Validate staging.orders
------------------------------------------------------------

SELECT
    COUNT_BIG(*) AS TotalRows,
    COUNT(DISTINCT order_id) AS DistinctOrders,

    SUM(
        CASE
            WHEN order_purchase_timestamp IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingPurchaseTimestamps,

    SUM(
        CASE
            WHEN order_delivered_customer_date IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingDeliveryTimestamps

FROM staging.orders;

------------------------------------------------------------
-- 6. Validate order status distribution
------------------------------------------------------------

SELECT
    order_status,
    COUNT_BIG(*) AS OrderCount
FROM staging.orders
GROUP BY order_status
ORDER BY OrderCount DESC;
GO