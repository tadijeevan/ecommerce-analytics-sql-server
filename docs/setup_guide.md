# Setup Guide — Olist E-commerce Analytics

## 1. Project Overview

This project analyzes the Olist Brazilian e-commerce dataset using Microsoft SQL Server.

The repository includes SQL scripts for database and schema setup, data ingestion, data quality validation, business analysis, and reporting views. It also includes a Power BI dashboard for visualizing business metrics.

## 2. Prerequisites

Before running the project, ensure you have:

* Microsoft SQL Server
* SQL Server Management Studio (SSMS)
* Access to the Olist dataset files
* Git, if you want to clone and version-control the repository
* Microsoft Power BI Desktop, if you want to open the dashboard

The SQL scripts are written for SQL Server and may require adjustments for other database platforms.

## 3. Clone the Repository

Clone the project repository:

git clone [https://github.com/tadijeevan/ecommerce-analytics-sql-server.git](https://github.com/tadijeevan/ecommerce-analytics-sql-server.git)

Navigate to the project directory:

cd ecommerce-analytics-sql-server

If you have already cloned the repository, open the existing project directory instead of cloning it again.

## 4. Database Setup

### Step 1: Connect to SQL Server

1. Open SQL Server Management Studio (SSMS).
2. Connect to your SQL Server instance.
3. Locate the SQL scripts in `sql/01_database_setup/`.

### Step 2: Create the Database and Schemas

Open and execute:

`sql/01_database_setup/01_create_database_and_schemas.sql`

This script creates the `EcommerceAnalytics` database and the following schemas if they do not already exist:

* `staging`
* `analytics`
* `reporting`

### Step 3: Create the Core Staging Tables

Open and execute:

`sql/01_database_setup/02_create_core_staging_tables.sql`

This script creates the following staging tables if they do not already exist:

* `staging.orders`
* `staging.customers`
* `staging.order_items`
* `staging.order_payments`
* `staging.order_reviews`

The script does not load data into these tables. It also does not validate or repair the structure of tables that already exist. If you are using an existing database, verify the table definitions before proceeding.

### Step 4: Prepare the Remaining Staging Tables

The product and seller ingestion scripts create the following tables if they do not already exist:

* `staging.products`
* `staging.sellers`

The `staging.geolocation` table must also exist before scripts that depend on it can run.

Its documented structure is:

| Column                        | Data type        | Nullable |
| ----------------------------- | ---------------- | -------- |
| `geolocation_zip_code_prefix` | `VARCHAR(5)`     | No       |
| `geolocation_lat`             | `DECIMAL(18,12)` | No       |
| `geolocation_lng`             | `DECIMAL(18,12)` | No       |
| `geolocation_city`            | `VARCHAR(100)`   | No       |
| `geolocation_state`           | `CHAR(2)`        | No       |

**Setup limitation:** The repository does not currently include a verified creation script for `staging.geolocation`. Ensure the table is created with the documented structure before running scripts that depend on it.

### Step 5: Import the Raw Olist Dataset

The database setup scripts do not create or import the raw Olist source tables.

Import the required dataset files separately into the `dbo` schema. The ingestion scripts expect source tables such as:

* `dbo.olist_orders_dataset`
* `dbo.olist_customers_dataset`
* `dbo.olist_order_items_dataset`
* `dbo.olist_order_payments_dataset`
* `dbo.olist_order_reviews_dataset`
* `dbo.olist_products_dataset`
* `dbo.olist_sellers_dataset`

Additional source tables may be required for geolocation and product-category translation.

Ensure that the source tables have the column names and compatible data types expected by the relevant ingestion scripts.

**Important:** The database setup scripts do not overwrite existing tables. However, creating a table only when it is missing does not guarantee that an existing table has the expected structure.

## 5. Data Ingestion

Data-ingestion scripts are located in:

`sql/02_data_ingestion/`

These scripts load raw Olist data into staging tables in the `EcommerceAnalytics` database.

### Ingestion Procedure

1. Confirm that the database and required staging tables exist.
2. Import the raw Olist dataset into the corresponding source tables under the `dbo` schema.
3. Review each ingestion script before execution.
4. Confirm that the target staging table is empty when the script requires an empty target.
5. Execute the relevant ingestion script.
6. Review its output and validation results.
7. Compare source and staging row counts where applicable.

### Orders Ingestion

The orders ingestion script is:

`sql/02_data_ingestion/01_load_orders.sql`

It loads data from `dbo.olist_orders_dataset` into `staging.orders`.

The script checks that the source and target tables exist, prevents loading when the target already contains data, uses a transaction, and validates the loaded row count.

**Important:** Do not execute the orders ingestion script against a database where `staging.orders` already contains records. The script intentionally stops to prevent duplicate loading.

For a fresh setup, ensure that the source table is populated and the target staging table is empty before running the script.

### Other Ingestion Scripts

Review the remaining scripts in `sql/02_data_ingestion/` before executing them.

Their validation and repeat-load safeguards differ. Do not assume every script has the same source checks, transaction handling, or duplicate-load protection.

Confirm that the required staging tables contain the expected data before proceeding to data-quality validation.

A successful execution against an existing database does not, by itself, establish that the entire project can be reproduced from a clean environment.

## 6. Data Quality Validation

Data-quality scripts are located in:

`sql/03_data_quality/`

These scripts help validate source data and relationships between tables.

Checks include:

* Row counts and distinct entity counts
* Missing values
* Duplicate keys or records
* Timestamp completeness and consistency
* Orphan records between related tables
* Geographic data quality

Run the relevant checks after loading the required staging tables.

Review the results before interpreting business-analysis outputs.

### Interpreting Data Quality Results

A data-quality warning does not automatically mean that records should be deleted.

For example:

* Repeated review identifiers should be investigated in the context of the source data and the table's intended grain.
* Repeated geolocation coordinates or ZIP-code prefixes may be legitimate.
* Missing optional review text does not necessarily indicate an invalid review.
* Timestamp inconsistencies should be evaluated before records are excluded from analysis.

Document any exclusions, assumptions, or data-cleaning decisions used in subsequent analysis.

## 7. Business Analysis

Business-analysis scripts are located in:

`sql/05_business_analysis/`

The scripts cover topics including:

* Monthly order and item-value trends
* Product-category performance
* Payment methods and installments
* Customer purchase behavior
* Customer cohorts and lifetime purchase value
* Seller performance
* Delivery performance
* Customer review scores
* Geographic analysis
* Monthly category rankings
* Rolling three-month item-value trends

Open the relevant SQL file in SSMS, review its metric definitions and filters, and execute the query.

For meaningful results:

1. Confirm that the required tables are populated.
2. Review the query's joins and aggregation grain.
3. Check the date filters and business definitions.
4. Verify that the output is consistent with the intended business question.

The repository contains 24 business-analysis SQL scripts. The documented business questions may cover multiple questions within a single script.

## 8. Reporting Views

Reporting-view scripts are located in:

`sql/06_reporting_views/`

Review and execute these scripts after the underlying staging tables have been loaded and validated.

The views provide reusable SQL logic for selected reporting metrics.

The current reporting views reference staging tables directly. A separate, implemented transformation layer should not be assumed.

Before using the views:

1. Confirm that their source tables exist.
2. Confirm that the required data has been loaded.
3. Execute the relevant view-definition scripts.
4. Query the views and inspect their results.
5. Validate important aggregates against the underlying data.

## 9. Power BI Dashboard

The Power BI dashboard is located at:

`powerbi/Ecommerce_Analytics_Dashboard.pbix`

An executive overview screenshot is available at:

`screenshots/executive_overview.png`

To review the dashboard:

1. Open the PBIX file in Microsoft Power BI Desktop.
2. Review the configured data-source and connection settings.
3. Connect to the appropriate SQL Server instance and database if prompted.
4. Confirm that the reporting views or other configured data sources exist.
5. Refresh the data if the environment and permissions permit.
6. Review the visuals, filters, and displayed metrics.

The dashboard file and screenshot are included in the repository. Successful refresh and validation in a clean environment should be confirmed separately; their presence alone does not establish that the dashboard can be refreshed without configuration changes.

## 10. Validation and Troubleshooting

After setup and ingestion:

1. Confirm that all required staging tables exist.
2. Confirm that the raw source tables are populated.
3. Compare source and staging row counts where applicable.
4. Run the data-quality scripts.
5. Investigate missing, duplicate, or orphaned records.
6. Execute representative business-analysis queries.
7. Validate key aggregates against the relevant source tables.
8. Execute the reporting-view scripts.
9. Confirm that the reporting views return the expected results.
10. Review Power BI connection settings and refresh behavior.

### Common Issues

**Invalid object name**

Check that the correct database is selected and that the referenced table or view exists in the expected schema.

**Table already contains data**

Some ingestion scripts are intended for one-time execution and stop when their target staging tables are populated. Review the script and existing data before deciding how to proceed.

**Invalid column name**

Confirm that the imported source table matches the column names expected by the ingestion script.

**Conversion errors**

Review the source data types, date formats, numeric values, and conversion logic.

**Unexpected row counts**

Check for repeated loads, rejected or converted records, join multiplication, and differences between source and target data.

**Power BI refresh errors**

Check the SQL Server connection, database name, permissions, and availability of the referenced tables and views.

Do not delete existing data or rerun ingestion scripts blindly to resolve an error.

## 11. Repository Structure

The main project directories are organized as follows:

ecommerce-analytics-sql-server/

* sql/

  * 01_database_setup/
  * 02_data_ingestion/
  * 03_data_quality/
  * 04_transformations/
  * 05_business_analysis/
  * 06_reporting_views/
  * scripts/
* docs/

  * business_questions.md
  * data_dictionary.md
  * findings.md
  * methodology.md
  * setup_guide.md
* powerbi/

  * Ecommerce_Analytics_Dashboard.pbix
* screenshots/

  * executive_overview.png
* README.md

Some directories may be empty or may not yet contain a fully implemented processing layer. Directory presence alone does not imply that the corresponding functionality has been implemented.

## 12. Data Source, License, and Reproducibility

### Data Source and License

The project uses the Olist Brazilian e-commerce dataset.

The dataset is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license (CC BY-NC-SA 4.0).

Review the dataset's original distribution terms and provide appropriate attribution when redistributing or using the data.

### Reproducibility Notes

The repository should be considered fully reproducible only after the complete setup, source-data import, ingestion, validation, reporting, and dashboard-refresh processes have been tested in a clean environment.

The current database may contain source tables and data loaded through steps that are not fully represented by the repository's scripts.

In particular:

* Raw Olist source tables must be imported separately.
* The creation procedure for `staging.geolocation` is not currently provided as a verified setup script.
* Existing tables are not automatically checked for schema compatibility by the core staging-table setup script.
* Ingestion scripts have different validation and repeat-load safeguards.
* Dashboard refresh behavior depends on the configured data source and environment.

Document any manual loading steps, external dependencies, and environment-specific settings before presenting the project as fully reproducible.
