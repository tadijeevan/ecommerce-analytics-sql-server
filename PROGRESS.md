# E-commerce Analytics Engineering with SQL Server

## Project Status
In Progress

## Current Phase
Database Setup and Initial Data Ingestion

## Completed
- Verified Git installation.
- Verified SQL Server Management Studio installation.
- Connected to SQL Server 2022 Express.
- Created the project folder structure.
- Created README.md and .gitignore.
- Initialized Git on the main branch.
- Created the GitHub repository and pushed the initial commit.
- Downloaded and extracted the Olist dataset into data/raw/.
- Verified that Git ignores the local dataset.
- Created the EcommerceAnalytics database.
- Created staging, analytics, and reporting schemas.
- Inspected the orders CSV structure.
- Created staging.orders with appropriate column data types.
- Imported the orders CSV into dbo.olist_orders_dataset using SSMS.
- Copied 99,441 records into staging.orders and converted timestamps to DATETIME2.
- Validated the staging.orders row count and timestamp range.
- Checked missing timestamp counts in staging.orders.

## Current Database Objects
- dbo.olist_orders_dataset: Imported orders source table; text-based columns.
- staging.orders: Typed staging table with 99,441 records.

## Data Quality Results
- Total orders: 99,441
- Missing purchase timestamps: 0
- Missing approval timestamps: 160
- Missing carrier timestamps: 1,783
- Missing customer delivery timestamps: 2,965
- Missing estimated delivery dates: 0

## Current Step
Document the initial orders ingestion process and prepare the remaining dataset imports.

## Next Steps
1. Save and commit the updated progress tracker.
2. Plan a repeatable import process for the remaining eight CSV files.
3. Create and populate the remaining staging tables.
4. Validate row counts, data types, and missing values.
5. Build the analytics layer.
6. Develop business analysis queries.
7. Create reporting views.
8. Build the Power BI dashboard.
9. Complete project documentation and publish updates to GitHub.

## Environment
- Database: Microsoft SQL Server 2022 Express
- SQL Server instance: DESKTOP-Q7I6VKD\SQLEXPRESS
- SQL client: SQL Server Management Studio
- Project language: T-SQL

## Issues
- The Import Wizard created dbo.olist_orders_dataset with VARCHAR columns.
- Records were copied into staging.orders with explicit timestamp conversion.
- The import workflow for the remaining datasets still needs to be established.

## Session Notes
The orders dataset was imported and validated on 2026-10-11.
