# E-commerce Analytics Engineering with SQL Server

An end-to-end data analytics engineering project using Microsoft SQL Server, Python, and Power BI to analyze the Brazilian E-Commerce Public Dataset by Olist.

The project covers data ingestion, data quality validation, SQL transformations, business analysis, reporting views, and an interactive Power BI dashboard.

## Project Overview

This project demonstrates how SQL and analytics engineering techniques can transform raw e-commerce data into actionable business insights.

The analysis covers orders, customers, payments, products, sellers, delivery performance, and customer satisfaction. It includes 30 documented business questions supported by SQL analysis scripts.

### Business Objectives

- Analyze monthly order and product revenue trends, including month-over-month growth.
- Identify top-performing products and categories by revenue, order count, and item volume.
- Understand payment methods, payment values, and installment distributions.
- Analyze customer geography, repeat purchases, cohorts, and lifetime purchase value.
- Evaluate seller performance, delivery delays, and geographic differences.
- Examine customer review scores and their relationship with delivery performance.
- Apply SQL techniques such as joins, CTEs, subqueries, conditional aggregation, ranking, and window functions.
- Validate data quality and document metric definitions before interpreting results.

## Technology Stack

| Technology | Purpose |
|---|---|
| Microsoft SQL Server 2022 Express | Database and SQL execution |
| T-SQL | Data validation, transformations, and business analysis |
| Python | Supporting data-loading utilities |
| pandas | Data handling in Python |
| pyodbc | Python connectivity to SQL Server |
| Power BI Desktop | Interactive dashboard and reporting |
| Git and GitHub | Version control and project documentation |

## Data Architecture

The project uses three SQL Server schemas to organize the data environment:

- **`staging`** — stores source datasets loaded into SQL Server.
- **`analytics`** — created for analytical transformations and calculations. A separate transformation layer is not currently implemented in the repository.
- **`reporting`** — contains reusable SQL views that calculate business metrics directly from staging tables.

### Analytical Workflow

The current SQL workflow consists of:

1. Load source datasets into the staging schema.
2. Run data quality checks to assess completeness, duplicates, timestamp consistency, and relationships.
3. Execute business-analysis queries for revenue, customers, products, payments, sellers, deliveries, and reviews.
4. Use reporting views to expose selected business metrics for reporting and Power BI.
5. Validate the results and document findings and limitations.

The reporting views currently reference staging tables directly. The `analytics` schema is created during database setup, but dedicated transformation objects have not been identified in the current SQL scripts.

### Data Sources

The project uses the following datasets from the Brazilian E-Commerce Public Dataset by Olist:

- Orders
- Customers
- Order items
- Order payments
- Order reviews
- Products
- Sellers
- Geolocation
- Product category name translations

Raw datasets are stored locally and excluded from Git version control.

## Data Quality and Validation

The project includes data quality checks covering:

- Source row counts and distinct business entities.
- Missing values in important columns.
- Duplicate business keys.
- Missing and inconsistent order timestamps.
- Orphan records in child tables.
- Product category and translation coverage.
- Geolocation coordinates, postal codes, and state coverage.
- Reporting output validation.

### Notable Data Quality Findings

- **Repeated review IDs:** 789 review IDs were repeated across 1,603 rows. The repeated IDs had consistent review scores and timestamps across the fields checked. The records were retained rather than automatically classified as invalid.
- **Geolocation duplicates:** 128,174 groups of exact duplicate geolocation records were identified, representing 261,831 excess rows. These were documented without automatically deleting source records.
- **Timestamp inconsistencies:** The checks identified order timestamp sequences requiring further investigation.
- **Referential integrity:** No orphan records were found in the order items, payments, and reviews checks.

Two additional product category mappings were added for categories missing from the supplied translation file. These are project-specific mappings and should not be interpreted as original source translations.

## SQL Reporting Views

The following reporting views were created in SQL Server:

| View | Purpose |
|---|---|
| `reporting.vw_monthly_revenue` | Monthly delivered product revenue, freight revenue, orders, and order items |
| `reporting.vw_category_performance` | Product category performance |
| `reporting.vw_payment_performance` | Payment method analysis |
| `reporting.vw_review_performance` | Customer review score analysis |
| `reporting.vw_seller_performance` | Seller performance analysis |

## Dashboard Preview

![E-commerce Analytics Executive Overview](screenshots/executive_overview.png)

## Power BI Dashboard

The Power BI report is available in the repository:

`powerbi/Ecommerce_Analytics_Dashboard.pbix`

The **Executive Overview** page contains:

- KPI cards for product revenue, delivered orders, freight revenue, and order items.
- Monthly product revenue trends.
- Top 10 product categories by revenue.
- Payment method analysis.
- Customer review score distribution.
- Top 10 sellers by product revenue.

To explore the report, open the PBIX file in Power BI Desktop and configure the SQL Server connection for your environment.

## Key Business Findings

### Revenue and Payments

- Health and beauty was the highest-revenue category among the analyzed categories.
- Credit cards represented the largest payment-value segment.
- Monthly delivered product revenue varied throughout the reporting period.

### Customer Reviews and Seller Performance

- Five-star reviews were the most common review score.
- Seller performance varied across revenue, order count, and item volume.
- **Positive reviews:** 77.07% of the 99,224 reviews analyzed received scores of 4 or 5.
- **Negative reviews:** 14.69% received scores of 1 or 2.

### Delivery Performance and Customer Satisfaction

- **Late deliveries:** 6,534 of 96,470 eligible delivered orders were late, representing 6.77%.
- **Average review scores:** Orders delivered early had an average review score of 4.29/5, compared with 2.27/5 for late deliveries.
- **Negative reviews and delivery:** 62.41% of reviews associated with late deliveries had scores of 1 or 2, compared with 9.23% for early deliveries.
- **Geographic variation:** Sao Paulo had an average delivery time of 8.70 days across 40,494 delivered orders. Roraima averaged 29.34 days across 41 orders, so its smaller sample size should be considered.

### Business Implications

The results suggest that delivery reliability deserves further investigation as part of customer-experience improvement efforts. Seller-level and geographic analyses can help identify where operational reviews may be most useful.

These findings describe the analyzed Olist dataset and should not be interpreted as representing the entire e-commerce industry. The observed relationship between delivery performance and review scores does not establish causation, and small sample sizes can make some comparisons less reliable.

## Metric Definitions and Limitations

- **Product revenue:** Sum of item prices for delivered orders.
- **Freight revenue:** Freight charges reported separately from product revenue.
- **Profit:** Not calculated in this project.
- **Average payment value:** Calculated at the payment-record level, not necessarily the order level.
- **Review distribution:** Based on the reviews included in the reporting view.
- **Missing categories:** Products with missing category information are not assigned invented source values.

## Repository Structure

The repository is organized into SQL scripts, supporting utilities, documentation, the Power BI report, and dashboard screenshots.

Important project paths include:

- `sql/01_database_setup/` — database and schema setup.
- `sql/02_data_ingestion/` — data ingestion scripts.
- `sql/03_data_quality/` — data quality checks.
- `sql/04_transformations/` — SQL transformations.
- `sql/05_business_analysis/` — business analysis queries.
- `sql/06_reporting_views/` — reporting view definitions.
- `sql/scripts/` — supporting Python utilities.
- `docs/` — project documentation.
- `powerbi/` — Power BI report.
- `screenshots/` — dashboard screenshots.

Refer to the repository for the complete file structure.

## Running the Project

For detailed setup instructions, database preparation, data loading, and execution guidance, refer to the [Setup Guide](docs/setup_guide.md).

### Prerequisites

- Microsoft SQL Server 2022 Express or a compatible SQL Server instance.
- SQL Server Management Studio (SSMS).
- Python and the required packages for the data-loading utility.
- Power BI Desktop.
- The original Olist datasets downloaded locally.

### Execution Overview

1. Configure SQL Server and create the `EcommerceAnalytics` database.
2. Create the required schemas and staging tables.
3. Load the source datasets into the staging tables.
4. Run the data quality validation scripts.
5. Execute the transformation and business analysis scripts in the documented order.
6. Create and validate the reporting views.
7. Open `powerbi/Ecommerce_Analytics_Dashboard.pbix` in Power BI Desktop.
8. Configure the SQL Server connection for your environment and refresh the report.

**Environment note:** Server names, database connections, and local dataset paths may need to be adjusted to match your environment.

## Documentation

The repository includes supporting documentation:

- [Setup Guide](docs/setup_guide.md) — project setup and execution instructions.
- [Business Questions](docs/business_questions.md) — documented business questions and their analytical scope.
- [Data Dictionary](docs/data_dictionary.md) — dataset and field reference.
- [Methodology](docs/methodology.md) — analytical approach and metric definitions.
- [Findings](docs/findings.md) — detailed analytical findings.

## Dataset Attribution

**Dataset:** Brazilian E-Commerce Public Dataset by Olist.

Source: [Olist Brazilian E-Commerce Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Refer to the original dataset page for attribution and licensing requirements.

## Project Status

**Status: Completed**

The project includes data ingestion, data quality validation, SQL analytics, reporting views, documentation, and an interactive Power BI dashboard.

The repository is intended to demonstrate practical SQL analytics engineering, data quality validation, business analysis, and BI reporting skills.