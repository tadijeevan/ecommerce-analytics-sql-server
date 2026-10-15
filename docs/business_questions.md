\# Business Questions and SQL Analysis



\## Project Overview



This project analyzes the Brazilian E-Commerce Public Dataset by Olist using Microsoft SQL Server. It focuses on data quality, customer behavior, product performance, payments, seller performance, delivery operations, and customer satisfaction.



The objective is to transform raw transactional data into meaningful business insights using SQL queries, aggregations, Common Table Expressions (CTEs), and window functions.



The project documents 30 business questions across seven analytical areas. These questions provide a structured framework for the SQL analysis.



\## 1. Data Quality and Validation



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q1 | What are the row counts and distinct entity counts across the source tables? | COUNT, COUNT DISTINCT |

| Q2 | Which columns contain missing or NULL values? | IS NULL, conditional aggregation |

| Q3 | Are there duplicate keys or duplicate records in the source data? | GROUP BY, HAVING |

| Q4 | Are there missing or inconsistent order timestamps? | NULL checks, date validation |

| Q5 | Are there orphan records between orders and related items, payments, and reviews? | JOINs, NOT EXISTS |



\## 2. Order and Payment Analysis



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q6 | How many orders are placed each month? | GROUP BY, date functions |

| Q7 | What is the distribution of orders by status? | GROUP BY, COUNT |

| Q8 | What is the monthly item value, excluding canceled or invalid orders? | JOINs, SUM, date functions |

| Q9 | How does average order value change over time? | Aggregation, monthly grouping |

| Q10 | What proportion of orders are canceled or unavailable? | Conditional aggregation |

| Q11 | How does freight value compare with item value? | JOINs, aggregation |

| Q12 | Which payment types are most frequently used? | GROUP BY, COUNT |

| Q13 | What is the distribution of payment installments? | GROUP BY, percentage calculations |



\## 3. Customer Analysis



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q14 | How are customers distributed by state and city? | GROUP BY, COUNT |

| Q15 | What percentage of customers make repeat purchases? | CTEs, aggregation |

| Q16 | How do customer cohorts behave over time? | CTEs, date functions, cohort analysis |

| Q17 | Which customers have the highest lifetime purchase value? | JOINs, SUM, ranking |



\## 4. Product and Category Analysis



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q18 | How does order value vary by geographic region? | JOINs, GROUP BY |

| Q19 | Which product categories generate the highest item value? | JOINs, SUM, ranking |

| Q20 | Which categories have the highest order counts and item volumes? | COUNT, SUM, GROUP BY |



\## 5. Seller Analysis



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q21 | How many orders are associated with each seller? | JOINs, COUNT |

| Q22 | How are sellers distributed geographically? | JOINs, GROUP BY |

| Q23 | Which sellers have the longest delivery delays? | Date functions, aggregation |

| Q28 | Which high-volume sellers have poor delivery performance? | CTEs, conditional aggregation, ranking |



\## 6. Delivery and Customer Satisfaction



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q24 | How do customer review scores vary across product categories? | JOINs, AVG, GROUP BY |

| Q25 | What percentage of delivered orders arrive after the estimated delivery date? | DATEDIFF, conditional aggregation |

| Q26 | How do delivery times vary by customer state? | JOINs, DATEDIFF, aggregation |

| Q27 | How does delivery performance relate to customer review scores? | CTEs, CASE, conditional aggregation, window functions |



\## 7. Advanced SQL Analysis



| ID | Business Question | SQL Concepts |

|---|---|---|

| Q29 | How do product categories rank by monthly item value? | CTEs, DENSE\_RANK or RANK |

| Q30 | What is the rolling three-month item value trend? | Window functions, rolling aggregates |



\## SQL Skills Demonstrated



The project demonstrates practical use of:



\- SELECT, WHERE, GROUP BY, and HAVING

\- INNER JOIN and LEFT JOIN

\- Aggregate functions: COUNT, SUM, AVG, MIN, and MAX

\- CASE expressions and conditional aggregation

\- Common Table Expressions (CTEs)

\- Subqueries

\- Date and time functions

\- NULL handling and data-quality checks

\- Window functions and ranking

\- Customer cohort analysis

\- Repeat-purchase analysis

\- Rolling-period calculations

\- Business metric definitions and validation



\## Important Metric Considerations



\- Item value, payment value, and freight value are different measures and should not be treated as interchangeable.

\- Revenue-related analyses must use clearly defined inclusion criteria for order statuses.

\- Joining order items, payments, and reviews can multiply rows. Aggregations must account for the grain of each table to avoid double counting.

\- Customer review scores and delivery performance indicate associations; they do not independently establish causation.

\- Delivery-performance classifications must use consistent definitions across SQL queries, reports, and documentation.

\- Results should be interpreted in the context of the dataset's coverage and limitations.

\- Small sample sizes can make comparisons between categories, sellers, or geographic regions less reliable.



\## Project Scope and Validation



This document maps the 30 business questions used to structure the SQL analysis.



The repository contains 24 SQL scripts in `sql/05\_business\_analysis/`. A single script may address multiple questions, so the number of scripts does not need to equal the number of business questions.



Documenting a question does not, by itself, certify that its query has been executed and validated. Query logic, output validation, and documented findings should be reviewed before the project is considered final.

