USE EcommerceAnalytics;
GO

/*
Analysis: Monthly Revenue and Month-over-Month Growth

ProductRevenue:
Sum of item prices for delivered orders.

FreightRevenue:
Sum of freight charges for delivered orders.

MoMRevenueGrowthPct:
Percentage change in product revenue compared with
the previous calendar month.
*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS RevenueMonth,
        SUM(oi.price) AS ProductRevenue,
        SUM(oi.freight_value) AS FreightRevenue,
        COUNT(DISTINCT o.order_id) AS TotalOrders
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),
DateBounds AS
(
    SELECT
        MIN(RevenueMonth) AS FirstMonth,
        MAX(RevenueMonth) AS LastMonth
    FROM MonthlyRevenue
),
CalendarMonths AS
(
    SELECT
        DATEADD(
            MONTH,
            n.Number,
            d.FirstMonth
        ) AS RevenueMonth
    FROM DateBounds AS d
    CROSS JOIN
    (
        SELECT
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Number
        FROM sys.all_objects
    ) AS n
    WHERE DATEADD(
        MONTH,
        n.Number,
        d.FirstMonth
    ) <= d.LastMonth
),
MonthlyResults AS
(
    SELECT
        c.RevenueMonth,
        COALESCE(m.ProductRevenue, 0) AS ProductRevenue,
        COALESCE(m.FreightRevenue, 0) AS FreightRevenue,
        COALESCE(m.TotalOrders, 0) AS TotalOrders
    FROM CalendarMonths AS c
    LEFT JOIN MonthlyRevenue AS m
        ON c.RevenueMonth = m.RevenueMonth
),
RevenueWithPreviousMonth AS
(
    SELECT
        RevenueMonth,
        ProductRevenue,
        FreightRevenue,
        TotalOrders,
        LAG(ProductRevenue) OVER (
            ORDER BY RevenueMonth
        ) AS PreviousMonthRevenue
    FROM MonthlyResults
)
SELECT
    RevenueMonth,
    TotalOrders,
    CAST(ProductRevenue AS DECIMAL(18, 2)) AS ProductRevenue,
    CAST(FreightRevenue AS DECIMAL(18, 2)) AS FreightRevenue,
    CAST(PreviousMonthRevenue AS DECIMAL(18, 2))
        AS PreviousMonthRevenue,
    CAST(
        CASE
            WHEN PreviousMonthRevenue IS NULL
              OR PreviousMonthRevenue = 0
            THEN NULL
            ELSE
                (
                    (ProductRevenue - PreviousMonthRevenue)
                    * 100.0
                ) / PreviousMonthRevenue
        END
        AS DECIMAL(10, 2)
    ) AS MoMRevenueGrowthPct
FROM RevenueWithPreviousMonth
ORDER BY RevenueMonth;
GO