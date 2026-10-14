USE EcommerceAnalytics;
GO

/*
Analysis: Order Value Distribution and Freight Analysis

Business questions:
1. What are the average, minimum, and maximum delivered order values?
2. How are delivered orders distributed across value bands?
3. How do freight charges compare with product item value?
4. What percentage of total order value is attributable to freight?

Metric definitions:
- ProductItemValue:
    Sum of product item prices.

- FreightCharges:
    Sum of freight charges associated with order items.

- TotalOrderValue:
    Product item value plus freight charges.

- AverageOrderValue:
    Average total order value per delivered order.

- FreightToItemValuePercentage:
    Total freight charges divided by total product item value,
    multiplied by 100.

- FreightPercentageOfTotalOrderValue:
    Total freight charges divided by total order value,
    multiplied by 100.

Scope:
- Delivered orders only.
- Order-level metrics are calculated after aggregating order items
  to one record per order.
- Currency: Brazilian reais (BRL).

Important:
- Product item value is not automatically equivalent to recognized
  accounting revenue or profit.
- Freight percentages use aggregate totals, not averages of
  individual order percentages.
*/

------------------------------------------------------------
-- 1. Summary metrics for delivered orders
------------------------------------------------------------

;WITH OrderValues AS
(
    SELECT
        o.order_id,
        SUM(oi.price) AS ProductItemValue,
        SUM(oi.freight_value) AS FreightCharges,
        SUM(oi.price) + SUM(oi.freight_value) AS TotalOrderValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS TotalDeliveredOrders,

    CAST(
        AVG(TotalOrderValue)
        AS DECIMAL(12, 2)
    ) AS AverageOrderValue,

    CAST(
        MIN(TotalOrderValue)
        AS DECIMAL(12, 2)
    ) AS MinimumOrderValue,

    CAST(
        MAX(TotalOrderValue)
        AS DECIMAL(12, 2)
    ) AS MaximumOrderValue,

    CAST(
        AVG(ProductItemValue)
        AS DECIMAL(12, 2)
    ) AS AverageProductItemValue,

    CAST(
        AVG(FreightCharges)
        AS DECIMAL(12, 2)
    ) AS AverageFreightCharges

FROM OrderValues;
GO

------------------------------------------------------------
-- 2. Distribution of delivered orders by value band
------------------------------------------------------------

;WITH OrderValues AS
(
    SELECT
        o.order_id,
        SUM(oi.price) + SUM(oi.freight_value) AS TotalOrderValue
    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
),
OrderBands AS
(
    SELECT
        CASE
            WHEN TotalOrderValue < 100
                THEN 'Under R$100'

            WHEN TotalOrderValue < 250
                THEN 'R$100 to R$249.99'

            WHEN TotalOrderValue < 500
                THEN 'R$250 to R$499.99'

            ELSE 'R$500 and above'
        END AS OrderValueBand,

        CASE
            WHEN TotalOrderValue < 100 THEN 1
            WHEN TotalOrderValue < 250 THEN 2
            WHEN TotalOrderValue < 500 THEN 3
            ELSE 4
        END AS SortOrder

    FROM OrderValues
)
SELECT
    OrderValueBand,
    COUNT(*) AS NumberOfOrders,

    CAST(
        100.0 * COUNT(*)
        / NULLIF(SUM(COUNT(*)) OVER (), 0)
        AS DECIMAL(5, 2)
    ) AS OrderPercentage

FROM OrderBands
GROUP BY
    OrderValueBand,
    SortOrder
ORDER BY SortOrder;
GO

------------------------------------------------------------
-- 3. Freight charges compared with product item value
------------------------------------------------------------

;WITH OrderFreightAnalysis AS
(
    SELECT
        o.order_id,
        SUM(oi.price) AS ProductItemValue,
        SUM(oi.freight_value) AS FreightCharges,

        SUM(oi.price)
        + SUM(oi.freight_value) AS TotalOrderValue

    FROM staging.orders AS o
    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS TotalDeliveredOrders,

    CAST(
        SUM(ProductItemValue)
        AS DECIMAL(15, 2)
    ) AS TotalProductItemValue,

    CAST(
        SUM(FreightCharges)
        AS DECIMAL(15, 2)
    ) AS TotalFreightCharges,

    CAST(
        SUM(TotalOrderValue)
        AS DECIMAL(15, 2)
    ) AS TotalOrderValueIncludingFreight,

    CAST(
        100.0 * SUM(FreightCharges)
        / NULLIF(SUM(ProductItemValue), 0)
        AS DECIMAL(10, 2)
    ) AS FreightToItemValuePercentage,

    CAST(
        100.0 * SUM(FreightCharges)
        / NULLIF(SUM(TotalOrderValue), 0)
        AS DECIMAL(10, 2)
    ) AS FreightPercentageOfTotalOrderValue

FROM OrderFreightAnalysis;
GO