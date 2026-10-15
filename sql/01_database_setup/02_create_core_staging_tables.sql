/*
Project: E-commerce Analytics Engineering with SQL Server
File: 02_create_core_staging_tables.sql

Purpose:
Create the core staging tables required by the ingestion scripts.

Tables created:
    staging.orders
    staging.customers
    staging.order_items
    staging.order_payments
    staging.order_reviews

Safety:
    - Creates the tables only when they do not exist.
    - Does not delete or overwrite existing tables.
    - Does not modify existing table data.
    - Preserves the column definitions and composite primary keys
      verified against the existing EcommerceAnalytics database.

Execution:
    Run 01_create_database_and_schemas.sql first.
    Then run this script before executing the relevant ingestion scripts.
*/

USE EcommerceAnalytics;
GO

SET NOCOUNT ON;
GO

------------------------------------------------------------
-- 1. Create staging.orders
------------------------------------------------------------

IF OBJECT_ID('staging.orders', 'U') IS NULL
BEGIN
    CREATE TABLE staging.orders
    (
        order_id VARCHAR(32) NOT NULL,
        customer_id VARCHAR(32) NOT NULL,
        order_status VARCHAR(20) NOT NULL,
        order_purchase_timestamp DATETIME2(0) NOT NULL,
        order_approved_at DATETIME2(0) NULL,
        order_delivered_carrier_date DATETIME2(0) NULL,
        order_delivered_customer_date DATETIME2(0) NULL,
        order_estimated_delivery_date DATETIME2(0) NULL
    );

    PRINT 'Created staging.orders';
END
ELSE
BEGIN
    PRINT 'staging.orders already exists; no changes made';
END;
GO

------------------------------------------------------------
-- 2. Create staging.customers
------------------------------------------------------------

IF OBJECT_ID('staging.customers', 'U') IS NULL
BEGIN
    CREATE TABLE staging.customers
    (
        customer_id VARCHAR(32) NOT NULL,
        customer_unique_id VARCHAR(32) NOT NULL,
        customer_zip_code_prefix VARCHAR(5) NULL,
        customer_city VARCHAR(100) NOT NULL,
        customer_state CHAR(2) NOT NULL
    );

    PRINT 'Created staging.customers';
END
ELSE
BEGIN
    PRINT 'staging.customers already exists; no changes made';
END;
GO

------------------------------------------------------------
-- 3. Create staging.order_items
------------------------------------------------------------

IF OBJECT_ID('staging.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE staging.order_items
    (
        order_id VARCHAR(32) NOT NULL,
        order_item_id INT NOT NULL,
        product_id VARCHAR(32) NOT NULL,
        seller_id VARCHAR(32) NOT NULL,
        shipping_limit_date DATETIME2(0) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        freight_value DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_order_items
            PRIMARY KEY (order_id, order_item_id)
    );

    PRINT 'Created staging.order_items';
END
ELSE
BEGIN
    PRINT 'staging.order_items already exists; no changes made';
END;
GO

------------------------------------------------------------
-- 4. Create staging.order_payments
------------------------------------------------------------

IF OBJECT_ID('staging.order_payments', 'U') IS NULL
BEGIN
    CREATE TABLE staging.order_payments
    (
        order_id VARCHAR(32) NOT NULL,
        payment_sequential INT NOT NULL,
        payment_type VARCHAR(30) NOT NULL,
        payment_installments INT NOT NULL,
        payment_value DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_order_payments
            PRIMARY KEY (order_id, payment_sequential)
    );

    PRINT 'Created staging.order_payments';
END
ELSE
BEGIN
    PRINT 'staging.order_payments already exists; no changes made';
END;
GO

------------------------------------------------------------
-- 5. Create staging.order_reviews
------------------------------------------------------------

IF OBJECT_ID('staging.order_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE staging.order_reviews
    (
        review_id VARCHAR(32) NOT NULL,
        order_id VARCHAR(32) NOT NULL,
        review_score INT NOT NULL,
        review_comment_title VARCHAR(1000) NULL,
        review_comment_message VARCHAR(4000) NULL,
        review_creation_date DATETIME2(0) NOT NULL,
        review_answer_timestamp DATETIME2(0) NULL,

        CONSTRAINT PK_order_reviews
            PRIMARY KEY (review_id, order_id)
    );

    PRINT 'Created staging.order_reviews';
END
ELSE
BEGIN
    PRINT 'staging.order_reviews already exists; no changes made';
END;
GO

------------------------------------------------------------
-- 6. Verify required tables exist
------------------------------------------------------------

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE s.name = 'staging'
  AND t.name IN
  (
      'orders',
      'customers',
      'order_items',
      'order_payments',
      'order_reviews'
  )
ORDER BY t.name;
GO