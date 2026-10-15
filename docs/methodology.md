\# SQL Analysis Methodology



\## 1. Overview



This document describes the methodology used in the Olist E-commerce Analytics project.



The project uses Microsoft SQL Server to analyze orders, customers, products, payments, sellers, deliveries, and customer reviews.



The analytical workflow consists of:

1\. Inspecting source tables and their structures.

2\. Validating data quality.

3\. Defining business metrics.

4\. Joining related datasets at the appropriate grain.

5\. Performing business analysis.

6\. Preparing reporting views and insights.



\## 2. Data Preparation



The project uses tables from the `staging` schema:



\- `staging.orders`

\- `staging.customers`

\- `staging.order\_items`

\- `staging.order\_payments`

\- `staging.order\_reviews`

\- `staging.products`

\- `staging.sellers`

\- `staging.geolocation`



The staging tables preserve the source data structure for analysis.



Before performing business analysis, data quality should be assessed through row counts, missing-value checks, duplicate checks, timestamp validation, and relationship checks.



\## 3. Data Quality Checks



\### 3.1 Row Counts and Distinct Entities



Row counts help establish the volume of data available in each table.



Distinct counts help assess the number of unique customers, orders, products, and sellers.



\### 3.2 Missing Values



Missing values are checked to understand data completeness.



A missing value is not automatically an error. For example, an undelivered order may not have an actual delivery timestamp.



\### 3.3 Duplicate Records



Potential duplicate keys are investigated using grouping and counting.



A repeated identifier must be interpreted in the context of the table's grain. For example, an order can legitimately have multiple order-item records.



\### 3.4 Timestamp Validation



Order lifecycle timestamps are examined for missing or inconsistent values.



Delivery metrics use orders with valid actual and estimated delivery timestamps.



\### 3.5 Relationship Validation



Related tables are checked for orphan records and unexpected relationship patterns.



Examples include order items, payments, and reviews that do not match an order in the orders table.



\## 4. Join Strategy and Data Grain



Each table represents a different level of detail.



| Table | Analytical Grain |

|---|---|

| Orders | Order |

| Customers | Customer record |

| Order items | Individual order item |

| Order payments | Payment record |

| Order reviews | Review record |

| Products | Product |

| Sellers | Seller |

| Geolocation | Geographic record |



Before joining tables, the expected grain of the output must be identified.



Joining multiple one-to-many tables can multiply records and inflate sums. For example, an order with multiple items and multiple payment records can produce repeated item and payment values when joined directly.



To reduce this risk:

1\. Identify the grain required by the business question.

2\. Aggregate data to the appropriate level where necessary.

3\. Join the aggregated datasets.

4\. Compare calculated totals against source-level totals.



\## 5. Business Metric Definitions



\### 5.1 Order Count



The number of orders is calculated using the order identifier at the appropriate order-level grain.



\### 5.2 Item Value



Item value is calculated using the sum of `staging.order\_items.price`.



The applicable order-status filters depend on the business question.



\### 5.3 Freight Value



Freight value is calculated using the sum of `staging.order\_items.freight\_value`.



\### 5.4 Payment Value



Payment value is calculated using the sum of `staging.order\_payments.payment\_value`.



Item value, freight value, and payment value are distinct measures and should not be treated as interchangeable.



\### 5.5 Average Order Value



Average order value is calculated by dividing the selected order-value measure by the number of eligible orders.



The order-value definition, eligible order statuses, and date range must be stated explicitly.



\### 5.6 Cancellation Rate



Cancellation and unavailable-order metrics are calculated using the relevant order statuses and a clearly defined denominator.



The treatment of unavailable orders should be documented separately from canceled orders when appropriate.



\### 5.7 Repeat Purchase Rate



Repeat-purchase analysis identifies customers with more than one eligible purchase.



The customer identifier and denominator must be consistent with the intended definition of a customer.



\### 5.8 Delivery Performance



Delivery variance is calculated using the difference between estimated and actual delivery dates.



For calendar-day classification:

\- Early: actual delivery date is before the estimated date.

\- On Time: actual and estimated delivery dates fall on the same calendar day.

\- Late: actual delivery date is after the estimated date.



Only records with valid actual and estimated delivery timestamps are eligible for this comparison.



\### 5.9 Review Analysis



Review scores are analyzed using the recorded review score.



For the delivery-versus-review analysis:

\- Negative reviews: scores of 1 or 2.

\- Neutral reviews: score of 3.

\- Positive reviews: scores of 4 or 5.



Review metrics should be calculated at the appropriate review or order-review association grain.



\## 6. SQL Techniques



The project uses SQL Server features including:



\- Aggregations and grouping

\- Conditional aggregation with CASE

\- INNER JOIN and LEFT JOIN

\- Common Table Expressions (CTEs)

\- Date and time functions

\- Subqueries

\- Window functions

\- Ranking functions

\- Percentage calculations

\- NULL handling



Window functions support analyses such as monthly category rankings and rolling three-month item-value trends.



\## 7. Reporting Views



Reporting views provide reusable query logic for selected business metrics.



Views should have clear names, documented metric definitions, and validated results.



The reporting layer should avoid duplicating complex logic unnecessarily and should preserve the intended grain of each metric.



\## 8. Interpretation and Limitations



The project is based on the available Olist dataset and its recorded transactions.



The results describe the data available for analysis and may not represent every aspect of the underlying business.



Additional considerations include:

\- Missing values and source-data limitations.

\- Different grains across related tables.

\- The possibility of inflated aggregates after joins.

\- The distinction between item value, freight value, and payment value.

\- Potential differences between order creation, approval, shipment, and delivery dates.

\- The fact that associations between delivery performance and review scores do not establish causation.



\## 9. Reproducibility



For reproducible analysis:

1\. Use the documented SQL Server database and schemas.

2\. Run data-quality checks before interpreting business metrics.

3\. Execute the relevant business-analysis scripts.

4\. Validate query results and metric definitions.

5\. Review reporting views after any changes to underlying logic.

6\. Record important findings and known limitations.



The setup guide should document the prerequisites, database setup, data loading, execution order, and validation steps required to reproduce the analysis.

