CREATE OR ALTER VIEW reporting.vw_review_performance
AS
SELECT
    r.review_score AS ReviewScore,
    COUNT(*) AS TotalReviews,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS ReviewPercentage
FROM staging.order_reviews AS r
INNER JOIN staging.orders AS o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND r.review_score IS NOT NULL
GROUP BY
    r.review_score;
GO