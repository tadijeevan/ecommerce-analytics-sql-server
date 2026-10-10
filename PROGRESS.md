\# E-commerce Analytics Engineering with SQL Server



\## Project Status

In Progress



\## Current Phase

Database Setup and Initial Data Ingestion



\## Completed

\- Verified Git installation.

\- Verified SQL Server Management Studio installation.

\- Connected to SQL Server 2022 Express.

\- Created the project folder structure.

\- Created README.md and .gitignore.

\- Initialized Git on the main branch.

\- Created the GitHub repository and pushed the initial commit.

\- Downloaded and extracted the Olist dataset into data/raw/.

\- Verified that Git ignores the local dataset.

\- Created the EcommerceAnalytics database.

\- Created staging, analytics, and reporting schemas.

\- Imported the orders CSV into dbo.olist\_orders\_dataset.

\- Created staging.orders with appropriate data types.

\- Loaded 99,441 records into staging.orders.

\- Converted order timestamps to DATETIME2.

\- Validated the orders row count and timestamp range.

\- Checked missing timestamp counts in staging.orders.

\- Imported the customers CSV into dbo.olist\_customers\_dataset.

\- Created and populated staging.customers with 99,441 records.

\- Validated customer IDs, unique customer IDs, and postal code values.

\- Inspected the order-items CSV structure.

\- Created staging.order\_items with appropriate data types and a composite primary key.

\- Imported 112,650 records into dbo.olist\_order\_items\_dataset.

\- Checked order-item data conversions and confirmed zero invalid values.

\- Checked for duplicate order\_id and order\_item\_id combinations; none found.

\- Loaded 112,650 records into staging.order\_items.

\- Validated order-item counts, distinct orders, distinct products, item value, freight value, and shipping date range.

\- Created the initial README.md, .gitignore, and project folder structure.

\- Saved the order-items ingestion script as 03\_load\_order\_items.sql.



\## Current Database Objects

\- dbo.olist\_orders\_dataset: Raw imported orders table.

\- staging.orders: Typed staging table with 99,441 records.

\- dbo.olist\_customers\_dataset: Raw imported customers table.

\- staging.customers: Staging table with 99,441 records.

\- dbo.olist\_order\_items\_dataset: Raw imported order-items table.

\- staging.order\_items: Typed staging table with 112,650 records.

\- analytics schema: Created; analytics tables/views not yet developed.

\- reporting schema: Created; reporting views not yet developed.



\## Data Quality Results



\### Orders

\- Total orders: 99,441

\- Missing purchase timestamps: 0

\- Missing approval timestamps: 160

\- Missing carrier timestamps: 1,783

\- Missing customer delivery timestamps: 2,965

\- Missing estimated delivery dates: 0



\### Customers

\- Total customer records: 99,441

\- Distinct customer IDs: 99,441

\- Distinct customer unique IDs: 96,096

\- Postal codes preserved as text, including leading zeros.



\### Order Items

\- Total order-item records: 112,650

\- Distinct orders in order items: 98,666

\- Distinct products: 32,951

\- Invalid item IDs: 0

\- Invalid shipping dates: 0

\- Invalid prices: 0

\- Invalid freight values: 0

\- Duplicate order\_id and order\_item\_id combinations: 0

\- Total item value: 13,591,643.70

\- Total freight value: 2,251,909.54

\- Earliest shipping limit: 2016-09-19

\- Latest shipping limit: 2020-04-09



\## Current Step

Completed initial ingestion and validation for orders, customers, and order items. Next, begin the payments dataset.



\## Next Steps

1\. Inspect the payments CSV structure.

2\. Create staging.order\_payments with appropriate data types.

3\. Import payments into a raw dbo table using SSMS.

4\. Validate payment values and duplicate/order relationships.

5\. Load and validate staging.order\_payments.

6\. Continue with the remaining CSV datasets.

7\. Create repeatable and rerunnable ingestion scripts.

8\. Build the analytics layer.

9\. Develop business analysis queries.

10\. Create reporting views.

11\. Build the Power BI dashboard.

12\. Complete project documentation and publish updates to GitHub.



\## Environment

\- Database: Microsoft SQL Server 2022 Express

\- SQL Server instance: DESKTOP-Q7I6VKD\\SQLEXPRESS

\- SQL client: SQL Server Management Studio

\- Project language: T-SQL

\- Git branch: main



\## Issues and Observations

\- SSMS Import Wizard created raw dbo tables with text-based columns.

\- Data was copied into typed staging tables using explicit conversions.

\- Missing order timestamps have been recorded for later investigation.

\- The latest order-item shipping limit is in April 2020, later than the main orders dataset. Investigate during data quality analysis.

\- The order-items script is an initial load script and is not yet safe to rerun without duplicating records.

\- The remaining CSV datasets still need to be imported and validated.

\- The latest SQL scripts and progress updates still need to be committed and pushed to GitHub.



\## Session Notes

\- Orders imported and validated on 2026-10-11.

\- Customers imported and validated on 2026-10-11.

\- Order items imported and validated on 2026-10-11.

\- Next session: continue with the payments dataset.

