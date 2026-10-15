\# Setup Guide — Olist E-commerce Analytics



\## 1. Project Overview



This project analyzes the Olist Brazilian e-commerce dataset using Microsoft SQL Server.



The repository includes SQL scripts for database setup, data ingestion, data quality validation, business analysis, and reporting views.



\## 2. Prerequisites



Before running the project, ensure you have:



\- Microsoft SQL Server

\- SQL Server Management Studio (SSMS)

\- Access to the Olist dataset files

\- Git, if you want to clone and version-control the project



The SQL scripts are written for SQL Server and may require adjustments for other database platforms.



\## 3. Clone the Repository



Clone the project repository:



&#x20;   git clone https://github.com/tadijeevan/ecommerce-analytics-sql-server.git



Navigate to the project directory:



&#x20;   cd ecommerce-analytics-sql-server



\## 4. Database Setup



1\. Open SQL Server Management Studio.

2\. Connect to your SQL Server instance.

3\. Open `sql/01\_database\_setup/01\_create\_database\_and\_schemas.sql`.

4\. Review the script and execute it to create the database and schemas.



The current project database is named `EcommerceAnalytics`.



The staging tables are located in the `staging` schema.



\## 5. Data Ingestion



The repository contains data-ingestion scripts under:



&#x20;   sql/02\_data\_ingestion/



Review the scripts before execution.



The ingestion process should load the source datasets into the corresponding staging tables.



\*\*Important:\*\* Confirm that all required source files and ingestion scripts are available before attempting a complete reload. Verify the loading process for every required table, including orders, before considering the setup fully reproducible.



\## 6. Data Quality Validation



Run the data-quality scripts under:



&#x20;   sql/03\_data\_quality/



These scripts help validate the source data and relationships between tables.



Review the results before interpreting business-analysis outputs.



Data-quality checks should include:



\- Row counts and distinct entity counts

\- Missing values

\- Duplicate keys or records

\- Timestamp completeness and consistency

\- Orphan records between related tables



\## 7. Business Analysis



The business-analysis scripts are located in:



&#x20;   sql/05\_business\_analysis/



The scripts cover topics including:



\- Monthly order and item-value trends

\- Product category performance

\- Payment methods and installments

\- Customer purchase behavior

\- Customer cohorts and lifetime purchase value

\- Seller performance

\- Delivery performance

\- Customer review scores

\- Geographic analysis

\- Monthly category rankings

\- Rolling three-month item-value trends



Open the relevant SQL file in SSMS, review its metric definitions and filters, and execute the query.



For meaningful results, ensure that the database contains the expected source data and that the query's assumptions are appropriate for the business question.



\## 8. Reporting Views



Reporting-view scripts are stored under:



&#x20;   sql/06\_reporting\_views/



Review and execute these scripts after the underlying staging tables have been loaded and validated.



The views provide reusable SQL logic for selected reporting metrics.



\## 9. Validation and Troubleshooting



After setup and ingestion:



1\. Confirm that all expected staging tables exist.

2\. Compare table row counts with the expected dataset counts.

3\. Run the data-quality scripts.

4\. Investigate missing or orphaned records.

5\. Execute representative business-analysis queries.

6\. Validate key aggregates against the relevant source tables.

7\. Confirm that reporting views return the expected results.



If a script fails, verify the database name, schema, source file paths, column names, permissions, and SQL Server compatibility.



\## 10. Repository Structure



&#x20;   sql/

&#x20;     01\_database\_setup/

&#x20;     02\_data\_ingestion/

&#x20;     03\_data\_quality/

&#x20;     04\_transformations/

&#x20;     05\_business\_analysis/

&#x20;     06\_reporting\_views/



&#x20;   docs/

&#x20;     business\_questions.md

&#x20;     data\_dictionary.md

&#x20;     findings.md

&#x20;     methodology.md

&#x20;     setup\_guide.md



\## 11. Data Source and License



The project uses the Olist Brazilian e-commerce dataset.



The dataset is distributed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license (CC BY-NC-SA 4.0).



Users should review the dataset's original distribution terms and provide appropriate attribution when redistributing or using the data.



\## 12. Reproducibility Notes



The repository should be treated as reproducible only after the complete setup and ingestion process has been tested from a clean environment.



The current database may contain source tables and data loaded through steps not represented by the scripts currently listed in the repository.



Document any manual loading steps, external dependencies, and environment-specific settings before presenting the project as fully reproducible.

