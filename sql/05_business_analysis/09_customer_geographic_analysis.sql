/*
Analysis: Customer Geographic Distribution
Purpose:
    Identify the states with the largest customer bases.
    Calculate each state's share of all unique customers.

Definitions:
    Unique customers are identified by customer_unique_id.
    Customer records are counted separately from unique customers.
    Percentages use the entire unique-customer population as the denominator.
*/

USE EcommerceAnalytics;
GO

WITH StateCustomers AS
(
    SELECT
        customer_state,
        COUNT(DISTINCT customer_unique_id) AS UniqueCustomers,
        COUNT(*) AS CustomerRecords
    FROM staging.customers
    GROUP BY customer_state
),
TotalCustomers AS
(
    SELECT
        COUNT(DISTINCT customer_unique_id) AS TotalUniqueCustomers
    FROM staging.customers
)
SELECT TOP 10
    s.customer_state AS CustomerState,
    s.UniqueCustomers,
    s.CustomerRecords,
    t.TotalUniqueCustomers,
    CAST(
        100.0 * s.UniqueCustomers / t.TotalUniqueCustomers
        AS DECIMAL(5, 2)
    ) AS PercentageOfAllCustomers
FROM StateCustomers AS s
CROSS JOIN TotalCustomers AS t
ORDER BY s.UniqueCustomers DESC;