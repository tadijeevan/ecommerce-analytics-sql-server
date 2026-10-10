# E-commerce Analytics Engineering with SQL Server

## 1. Project Overview

This project uses Microsoft SQL Server and T-SQL to analyze e-commerce operations, customer purchasing behaviour, product performance, seller performance, delivery delays, and customer satisfaction.

The project transforms multiple related CSV files into a structured analytical database and answers business questions through reusable SQL queries and reporting views.

## 2. Business Objectives

- Analyze order volume and order-value trends.
- Identify high-performing products, categories, and sellers.
- Understand repeat purchasing and customer value.
- Measure delivery performance and delivery delays.
- Investigate relationships between delivery experience and review scores.
- Create reusable SQL views for reporting and Power BI.

## 3. Dataset

Brazilian E-Commerce Public Dataset by Olist.

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains approximately 100,000 orders from 2016–2018 and includes related order, item, customer, seller, product, payment, review, and location data.

The dataset is licensed under CC BY-NC-SA 4.0. Review the original dataset page for its attribution and reuse requirements.

The original dataset will be stored locally and will not be committed to GitHub.

## 4. Technology Stack

- Microsoft SQL Server 2022 Express
- SQL Server Management Studio (SSMS)
- T-SQL
- Git
- GitHub
- Power BI Desktop (planned)

## 5. Project Architecture

Raw CSV files -> Staging tables -> Data validation and transformations -> Analytical layer -> Reporting views -> Power BI

## 6. Project Structure

ecommerce-analytics-sql-server/
  data/
    raw/
    processed/
  sql/
    01_database_setup/
    02_data_ingestion/
    03_data_quality/
    04_transformations/
    05_business_analysis/
    06_reporting_views/
  powerbi/
  screenshots/
  docs/
  .gitignore
  README.md
  PROGRESS.md

## 7. Planned Analysis

- Data quality and database integrity.
- Monthly order volume and order status.
- Item value and average order value.
- Payment methods and freight costs.
- Customer purchasing behaviour and repeat purchases.
- Product category and seller performance.
- Delivery times and estimated delivery dates.
- Review scores and customer satisfaction.
- Advanced SQL using CTEs, window functions, rankings, and rolling averages.

## 8. How to Run

1. Install SQL Server and SSMS.
2. Download the dataset from the source listed above.
3. Extract the CSV files into data/raw/ locally.
4. Execute the database setup scripts.
5. Create and populate the staging tables.
6. Run data validation and transformation scripts.
7. Execute the business analysis queries.
8. Create the reporting views.
9. Connect Power BI Desktop to the local SQL Server instance if using the dashboard.

Detailed instructions will be added as the project develops.

## 9. Key Findings

To be completed after executing and validating the SQL analysis. All reported figures and conclusions will be supported by actual query results.

## 10. Limitations

The dataset represents a historical and anonymized view of e-commerce activity. Item value should not automatically be interpreted as recognized revenue or profit. Relationships between delivery delays and review scores should not be interpreted as causal without further evidence.

## 11. Project Status

Currently in the environment setup and project initialization phase.

## 12. Acknowledgements

Dataset provided by Olist through Kaggle. Dataset rights and reuse conditions remain subject to the original license.

This project is intended for educational and analytical portfolio purposes.
