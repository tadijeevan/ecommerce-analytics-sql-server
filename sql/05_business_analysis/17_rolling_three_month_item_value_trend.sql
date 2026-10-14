USE EcommerceAnalytics;
GO

/*
Purpose:
    Calculate monthly item value and its rolling three-month trend.

Business question:
    How does item value change over time, and what is the
    rolling three-month average?

Metrics:
    - Monthly item value
    - Previous month's item value
    - Month-over-month change
    - Rolling three-month item value
    - Rolling three-month average

Methodology:
    1. Include delivered orders only.
    2. Aggregate item value by calendar month.
    3. Generate a continuous sequence of months.
    4. Fill months without item value with zero.
    5. Calculate rolling metrics over three consecutive months.

Note:
    Item value excludes freight.
    This is not a profit or accounting-revenue calculation.
*/

WITH MonthlyItemValue AS (
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS OrderMonth,
        SUM(oi.price) AS MonthlyItemValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        )
),
MonthRange AS (
    SELECT
        MIN(OrderMonth) AS FirstMonth,
        MAX(OrderMonth) AS LastMonth
    FROM MonthlyItemValue
),
CalendarMonths AS (
    SELECT FirstMonth AS OrderMonth
    FROM MonthRange

    UNION ALL

    SELECT DATEADD(MONTH, 1, cm.OrderMonth)
    FROM CalendarMonths AS cm
    CROSS JOIN MonthRange AS mr
    WHERE cm.OrderMonth < mr.LastMonth
),
CompleteMonthlyValues AS (
    SELECT
        cm.OrderMonth,
        CAST(
            COALESCE(miv.MonthlyItemValue, 0)
            AS DECIMAL(18, 2)
        ) AS MonthlyItemValue
    FROM CalendarMonths AS cm
    LEFT JOIN MonthlyItemValue AS miv
        ON cm.OrderMonth = miv.OrderMonth
),
MonthlyTrends AS (
    SELECT
        OrderMonth,
        MonthlyItemValue,
        LAG(MonthlyItemValue) OVER (
            ORDER BY OrderMonth
        ) AS PreviousMonthItemValue,
        SUM(MonthlyItemValue) OVER (
            ORDER BY OrderMonth
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS RollingThreeMonthItemValue,
        AVG(CAST(MonthlyItemValue AS DECIMAL(18, 2))) OVER (
            ORDER BY OrderMonth
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS RollingThreeMonthAverage
    FROM CompleteMonthlyValues
)
SELECT
    OrderMonth,
    MonthlyItemValue,
    PreviousMonthItemValue,
    CAST(
        MonthlyItemValue - PreviousMonthItemValue
        AS DECIMAL(18, 2)
    ) AS MonthOverMonthChange,
    CAST(
        RollingThreeMonthItemValue
        AS DECIMAL(18, 2)
    ) AS RollingThreeMonthItemValue,
    CAST(
        RollingThreeMonthAverage
        AS DECIMAL(18, 2)
    ) AS RollingThreeMonthAverage
FROM MonthlyTrends
ORDER BY OrderMonth
OPTION (MAXRECURSION 100);