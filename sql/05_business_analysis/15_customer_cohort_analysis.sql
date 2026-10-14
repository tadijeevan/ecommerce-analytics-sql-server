USE EcommerceAnalytics;
GO

/*
Purpose:
    Analyze customer cohorts based on their first purchase month.

Business question:
    Which customer cohorts generate the most subsequent orders?

Methodology:
    1. Identify each customer's first recorded purchase month.
    2. Assign customers to cohorts based on that month.
    3. Count orders placed by each cohort in each subsequent month.
    4. Compare subsequent ordering activity across cohorts.

Definitions:
    CohortMonth:
        Month of the customer's first recorded order.

    OrderMonth:
        Month in which an order was placed.

    MonthsSinceFirstPurchase:
        Number of calendar months between the cohort month
        and the order month.

    CustomersInCohort:
        Total distinct customers in the original cohort.
        This remains constant across all months for that cohort.

    TotalOrders:
        Distinct orders placed by the cohort during the month.

    SubsequentOrders:
        Distinct orders placed after the cohort month.
        Orders in the original cohort month are excluded.

Scope:
    All order statuses are included.
    Orders without a purchase timestamp are excluded.

Sources:
    staging.customers
    staging.orders

Grain:
    One row per cohort month and order month.
*/

WITH CustomerFirstPurchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS FirstPurchaseTimestamp
    FROM staging.customers AS c
    INNER JOIN staging.orders AS o
        ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        c.customer_unique_id
),

CustomerCohorts AS (
    SELECT
        customer_unique_id,
        DATEFROMPARTS(
            YEAR(FirstPurchaseTimestamp),
            MONTH(FirstPurchaseTimestamp),
            1
        ) AS CohortMonth
    FROM CustomerFirstPurchase
),

CustomerOrders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS OrderMonth
    FROM staging.customers AS c
    INNER JOIN staging.orders AS o
        ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp IS NOT NULL
),

CohortSizes AS (
    SELECT
        CohortMonth,
        COUNT(DISTINCT customer_unique_id) AS CustomersInCohort
    FROM CustomerCohorts
    GROUP BY
        CohortMonth
)

SELECT
    cc.CohortMonth,
    co.OrderMonth,

    DATEDIFF(
        MONTH,
        cc.CohortMonth,
        co.OrderMonth
    ) AS MonthsSinceFirstPurchase,

    cs.CustomersInCohort,

    COUNT(DISTINCT co.order_id) AS TotalOrders,

    COUNT(
        DISTINCT CASE
            WHEN co.OrderMonth > cc.CohortMonth
            THEN co.order_id
        END
    ) AS SubsequentOrders

FROM CustomerCohorts AS cc

INNER JOIN CustomerOrders AS co
    ON cc.customer_unique_id = co.customer_unique_id

INNER JOIN CohortSizes AS cs
    ON cc.CohortMonth = cs.CohortMonth

WHERE co.OrderMonth >= cc.CohortMonth

GROUP BY
    cc.CohortMonth,
    co.OrderMonth,
    cs.CustomersInCohort

ORDER BY
    cc.CohortMonth,
    co.OrderMonth;