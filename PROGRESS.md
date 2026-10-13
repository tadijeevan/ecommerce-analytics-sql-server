# E-commerce Analytics Engineering with SQL Server

## Project Status
Core implementation completed; final documentation and validation in progress.

## Project Overview
An end-to-end e-commerce analytics project using SQL Server, T-SQL, Python-based ingestion scripts, and Power BI to analyze the Olist Brazilian e-commerce dataset.

## Completed Work

### 1. Project Setup
- Created the project folder structure.
- Configured Git and GitHub version control.
- Downloaded and organized the Olist dataset locally.
- Configured `.gitignore` to exclude raw data and the Python virtual environment.

### 2. Database and Data Ingestion
- Created the `EcommerceAnalytics` database.
- Organized data using `staging`, `analytics`, and `reporting` schemas.
- Loaded orders, customers, order items, payments, reviews, products, sellers, and geolocation data.
- Loaded product-category translations.
- Added two project-specific category mappings for previously unmapped categories.
- Preserved missing product categories rather than inventing source values.

### 3. Data Quality and Validation
- Validated source row counts and key fields.
- Checked geolocation coordinates, postal-code prefixes, and state coverage.
- Checked product-category translation coverage.
- Verified that products with missing categories remain identifiable.

### 4. SQL Analytics
- Analyzed monthly delivered product revenue and freight revenue.
- Calculated month-over-month revenue growth.
- Ranked product categories by revenue.
- Analyzed payment methods and payment values.
- Examined customer review-score distribution.
- Ranked sellers by delivered product revenue.

### 5. Reporting Views
Created and verified these SQL Server views:

- `reporting.vw_monthly_revenue`
- `reporting.vw_category_performance`
- `reporting.vw_payment_performance`
- `reporting.vw_review_performance`
- `reporting.vw_seller_performance`

### 6. Power BI
- Connected Power BI Desktop to SQL Server.
- Imported the five reporting views.
- Created an Executive Overview dashboard.
- Added KPI cards for product revenue, delivered orders, freight revenue, and order items.
- Added monthly revenue, category performance, payment analysis, review distribution, and seller performance visuals.
- Saved the report under `powerbi/Ecommerce_Analytics_Dashboard.pbix`.

### 7. Version Control
- Committed project scripts and reporting assets.
- Pushed the current implementation to GitHub.

## Key Business Findings

- Health and beauty was the highest-revenue category among the analyzed categories.
- Credit cards represented the largest payment-value segment.
- Five-star reviews were the most common review score.
- Seller performance varied by product revenue, order count, and item volume.
- Monthly delivered product revenue varied substantially across the reporting period.

## Remaining Tasks
- Finalize README documentation.
- Add a dashboard screenshot.
- Perform final SQL and Power BI validation.
- Commit and push final documentation changes.

## Important Metric Definitions
- Product revenue is based on item prices for delivered orders.
- Freight revenue is reported separately from product revenue.
- Payment averages are averages per payment record, not necessarily per order.
- Review percentages are calculated over the reviews included in the reporting view.
- Product revenue is not the same as profit.

## Dataset
Brazilian E-Commerce Public Dataset by Olist.

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Review the dataset's original license and attribution requirements before redistribution.