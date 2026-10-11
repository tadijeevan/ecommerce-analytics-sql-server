# E-commerce Analytics Engineering with SQL Server



## Project Status

In Progress



## Current Phase

Database Setup and Initial Data Ingestion



## Completed



### Project Setup

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



### Orders

- Imported the orders CSV into dbo.olist_orders_dataset.

- Created staging.orders with appropriate data types.

- Loaded 99,441 records into staging.orders.

- Converted order timestamps to DATETIME2.

- Validated the orders row count and timestamp range.

- Checked missing timestamp counts in staging.orders.



### Customers

- Imported the customers CSV into dbo.olist_customers_dataset.

- Created and populated staging.customers with 99,441 records.

- Validated customer IDs, unique customer IDs, and postal code values.



### Order Items

- Inspected the order-items CSV structure.

- Imported 112,650 records into dbo.olist_order_items_dataset.

- Created staging.order_items with appropriate data types and a composite primary key.

- Checked order-item data conversions and confirmed zero invalid values.

- Checked for duplicate order_id and order_item_id combinations; none found.

- Loaded 112,650 records into staging.order_items.

- Validated order-item counts, distinct orders, distinct products, item value, freight value, and shipping date range.

- Saved the order-items ingestion script as sql/02_data_ingestion/03_load_order_items.sql.



### Payments

- Imported 103,886 payment records into dbo.olist_order_payments_dataset.

- Created and populated staging.order_payments with 103,886 records.

- Validated payment types, installments, payment values, and duplicate keys.

- Saved the payment ingestion script as sql/02_data_ingestion/04_load_order_payments.sql.



### Reviews

- Imported 99,224 review records into dbo.olist_order_reviews_dataset.

- Created and populated staging.order_reviews with 99,224 records.

- Investigated duplicate review IDs and preserved all review records using a composite primary key.

- Validated review scores, timestamps, and missing comments.

- Saved the review ingestion script as sql/02_data_ingestion/05_load_order_reviews.sql.



### Products

- Imported 32,951 product records into dbo.olist_products_dataset.

- Created and populated staging.products with 32,951 records.

- Validated product IDs and documented missing product attributes.

- Preserved missing product attributes as NULL in staging.products.

- Saved the products ingestion script as sql/02_data_ingestion/06_load_products.sql.



### Sellers

- Imported 3,095 seller records into dbo.olist_sellers_dataset.

- Created and populated staging.sellers with 3,095 records.

- Validated seller IDs and confirmed zero duplicate IDs.

- Confirmed 23 unique states and 611 unique cities.

- Confirmed zero missing seller IDs and postal codes in staging.

- Stored seller postal codes as VARCHAR in staging.sellers.

- Saved the sellers ingestion script as sql/02_data_ingestion/07_load_sellers.sql.



### Geolocation

- Inspected the geolocation CSV structure, encoding, file size, and data quality using Python.

- Confirmed that the original CSV contains 1,000,163 records.

- Identified 19,015 unique postal code prefixes, 27 states, and 8,011 distinct city names in the original Python inspection.

- Identified 261,831 exact duplicate rows in the original dataset.

- Imported the geolocation CSV into dbo.olist_geolocation_dataset.

- Identified character encoding corruption in city names from the SQL Server Import Wizard.

- Created dbo.olist_geolocation_unicode with an NVARCHAR city column.

- Created scripts/load_geolocation.py to load the original UTF-8 CSV using pandas and pyodbc.

- Loaded 1,000,163 records into dbo.olist_geolocation_unicode.

- Confirmed that Portuguese city names, including são paulo, were preserved correctly.

- Confirmed that postal codes such as 01001 retained their leading zeros.

- Created and populated staging.geolocation.

- Increased latitude and longitude precision to DECIMAL(18,12).

- Resolved a scientific-notation latitude conversion issue by converting coordinates through FLOAT before DECIMAL(18,12).

- Reloaded staging.geolocation from dbo.olist_geolocation_unicode inside a transaction.

- Validated the staging row count, postal code coverage, states, cities, and coordinate ranges.



## Current Database Objects



### Raw Tables

- dbo.olist_orders_dataset: Raw imported orders table.

- dbo.olist_customers_dataset: Raw imported customers table.

- dbo.olist_order_items_dataset: Raw imported order-items table.

- dbo.olist_order_payments_dataset: Raw imported payments table.

- dbo.olist_order_reviews_dataset: Raw imported reviews table.

- dbo.olist_products_dataset: Raw imported products table.

- dbo.olist_sellers_dataset: Raw imported sellers table.

- dbo.olist_geolocation_dataset: Raw imported geolocation table.



### Additional Geolocation Table

- dbo.olist_geolocation_unicode: Unicode-preserving geolocation source loaded directly from the original UTF-8 CSV.



### Staging Tables

- staging.orders: Typed staging table with 99,441 records.

- staging.customers: Staging table with 99,441 records.

- staging.order_items: Typed staging table with 112,650 records.

- staging.order_payments: Staging table with 103,886 records.

- staging.order_reviews: Staging table with 99,224 records.

- staging.products: Typed staging table with 32,951 records.

- staging.sellers: Typed staging table with 3,095 records.

- staging.geolocation: Typed geolocation staging table with 1,000,163 records.



### Other Schemas

- staging: Created and populated with eight datasets.

- analytics: Created; analytics tables and views are not yet developed.

- reporting: Created; reporting views are not yet developed.



## Data Quality Results



### Orders

- Total orders: 99,441.

- Missing purchase timestamps: 0.

- Missing approval timestamps: 160.

- Missing carrier timestamps: 1,783.

- Missing customer delivery timestamps: 2,965.

- Missing estimated delivery dates: 0.

- Purchase timestamp range: 2016-09-04 to 2018-10-17.



### Customers

- Total customer records: 99,441.

- Distinct customer IDs: 99,441.

- Distinct customer unique IDs: 96,096.

- Postal codes preserved as text, including leading zeros.



### Order Items

- Total order-item records: 112,650.

- Distinct orders in order items: 98,666.

- Distinct products: 32,951.

- Invalid item IDs: 0.

- Invalid shipping dates: 0.

- Invalid prices: 0.

- Invalid freight values: 0.

- Duplicate order_id and order_item_id combinations: 0.

- Total item value: 13,591,643.70.

- Total freight value: 2,251,909.54.

- Earliest shipping limit: 2016-09-19.

- Latest shipping limit: 2020-04-09.



### Payments

- Total payment records: 103,886.

- Distinct orders: 99,440.

- Distinct payment types: 5.

- Missing payment types: 0.

- Invalid payment sequences: 0.

- Invalid payment installments: 0.

- Invalid payment values: 0.

- Duplicate order_id and payment_sequential combinations: 0.

- Total payment value: 16,008,872.12.

- Zero-value payments: 9.

- Minimum payment value: 0.

- Maximum payment value: 13,664.08.



### Reviews

- Total review records: 99,224.

- Distinct review IDs: 98,410.

- Distinct order IDs: 98,673.

- Review scores range from 1 to 5.

- Review IDs appearing multiple times: 789.

- Extra rows associated with repeated review IDs: 814.

- Duplicate review_id and order_id combinations: 0.

- Missing review titles: 87,658.

- Missing review messages: 58,256.

- All review records preserved using the composite primary key (review_id, order_id).



### Products

- Total product records: 32,951.

- Distinct product IDs: 32,951.

- Missing product IDs: 0.

- Missing product categories: 610.

- Missing product name lengths: 610.

- Missing product description lengths: 610.

- Missing photo quantities: 610.

- Missing product weights: 2.

- Products missing dimensions: 2.

- Missing product attributes preserved as NULL in staging.products.



### Sellers

- Total seller records: 3,095.

- Distinct seller IDs: 3,095.

- Duplicate seller IDs: 0.

- Missing seller IDs: 0.

- Missing seller postal codes: 0.

- Missing seller cities: 0.

- Missing seller states: 0.

- Unique seller states: 23.

- Unique seller cities: 611.

- Seller postal codes are stored as VARCHAR in staging.sellers.

- Potential loss of leading zeros during raw integer import remains to be checked against the original CSV.



### Geolocation

- Total geolocation records: 1,000,163.

- Distinct postal code prefixes: 19,015.

- Distinct states: 27.

- Distinct cities in staging.geolocation: 8,010.

- Missing coordinates: 0.

- Invalid or out-of-range coordinates: 0.

- Portuguese city names preserved correctly.

- Postal codes with leading zeros preserved correctly.

- Latitude and longitude stored as DECIMAL(18,12).

- Original CSV exact duplicate rows: 261,831, as determined during Python inspection.

- All source rows were preserved in staging.geolocation, including repeated postal code prefixes and repeated coordinate records.



## Current Step

Completed initial ingestion and validation for:

- Orders
- Customers
- Order items
- Payments
- Reviews
- Products
- Sellers
- Geolocation

The product category translation CSV has been inspected. It contains 71 rows and 2 columns, with no missing values or duplicates. The raw table `dbo.product_category_name_translation` has been created successfully, but the 71 CSV records have not yet been imported.

Next: import the translation CSV into the raw table, create and validate its staging table, and save the ingestion SQL script.

## Next Steps



1. Inspect and import the product category translation dataset.

2. Create and validate a staging table for product category translations.

3. Review data quality across all staging tables.

4. Investigate data-quality observations and cross-table relationships.

5. Review referential integrity between orders, customers, order items, payments, reviews, products, sellers, and geolocation.

6. Investigate the latest order-item shipping limit date of 2020-04-09.

7. Investigate the difference between order counts across orders, order items, and payments.

8. Review seller postal-code leading zeros against the original CSV.

9. Build the analytics layer and establish appropriate relationships.

10. Develop business analysis queries.

11. Create reporting views.

12. Build the Power BI dashboard.

13. Improve ingestion scripts for safe reruns.

14. Complete project documentation.

15. Commit and push project updates to GitHub.



## Environment



- Database: Microsoft SQL Server 2022 Express.

- SQL Server instance: DESKTOP-Q7I6VKD\SQLEXPRESS.

- SQL client: SQL Server Management Studio.

- Project language: T-SQL, with Python for CSV inspection and geolocation ingestion.

- Git branch: main.

- Python version used for CSV inspection and ingestion: Python 3.13.6.

- pandas version used for CSV inspection and ingestion: 3.0.6.

- pyodbc version: 5.3.0.

- ODBC driver: ODBC Driver 17 for SQL Server.



## Issues and Observations



- SSMS Import Wizard created raw dbo tables with text-based columns in most imports.

- Data was copied into typed staging tables using explicit conversions.

- Missing order timestamps have been recorded for later investigation.

- The latest order-item shipping limit is in April 2020, later than the main orders dataset. Investigate during data-quality analysis.

- The orders dataset contains 99,441 orders, while order items contain 98,666 distinct orders.

- The payments dataset contains 99,440 distinct orders.

- Repeated review IDs were investigated; records were preserved using the composite key (review_id, order_id).

- The products dataset contains 610 records with missing category and related descriptive attributes.

- Two products have missing weight and dimension information.

- The sellers raw import detected seller_zip_code_prefix as an integer. Any leading zeros lost during import may need to be recovered from the original CSV.

- Initial ingestion scripts should be reviewed and improved to support safe reruns.

- The geolocation Import Wizard process corrupted Unicode city names. The issue was resolved by loading the original UTF-8 CSV directly into an NVARCHAR destination using Python and pyodbc.

- Geolocation coordinates are stored as DECIMAL(18,12). Scientific notation in the original latitude required an intermediate FLOAT conversion.

- The product category translation CSV has been inspected: 71 rows, no missing values, and no duplicate category names. The raw table dbo.product_category_name_translation has been created, but the CSV records have not yet been imported.

- SQL scripts and progress updates need to be committed and pushed to GitHub.



## Session Notes




- Product category translation dataset inspected on 2026-10-11: 71 rows, 2 columns, no missing values, and no duplicates.
- Created dbo.product_category_name_translation on 2026-10-11; CSV import remains pending.

- Orders imported and validated on 2026-10-11: 99,441 records.

- Customers imported and validated on 2026-10-11: 99,441 records.

- Order items imported and validated on 2026-10-11: 112,650 records.

- Payments imported and validated on 2026-10-11: 103,886 records.

- Reviews imported and validated on 2026-10-11: 99,224 records.

- Products imported and validated on 2026-10-11: 32,951 records.

- Sellers imported and validated on 2026-10-11: 3,095 records.

- Geolocation imported and validated on 2026-10-11: 1,000,163 records.

- Review data quality: 789 review IDs appear multiple times, representing 814 extra rows.

- Preserved all review records using the composite primary key (review_id, order_id).

- Products data quality: 610 missing categories and 2 products missing weight and dimension information.

- Sellers data quality: 3,095 unique seller IDs, 23 states, and 611 cities.

- Geolocation data quality: 19,015 postal code prefixes, 27 states, 8,010 cities in staging, zero missing coordinates, and zero invalid coordinates.

- Created sql/02_data_ingestion/04_load_order_payments.sql.

- Created sql/02_data_ingestion/05_load_order_reviews.sql.

- Created sql/02_data_ingestion/06_load_products.sql.

- Created sql/02_data_ingestion/07_load_sellers.sql.

- Created scripts/load_geolocation.py.

- Next: inspect and import the product category translation dataset.

