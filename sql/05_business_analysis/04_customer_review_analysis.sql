USE EcommerceAnalytics;
GO

/*
Analysis: Customer Review Score Distribution

Business questions:
1. How are customer reviews distributed across scores from 1 to 5?
2. What percentage of reviews does each score represent?
3. What proportion of reviews are positive?
4. What proportion of reviews are negative?

Metric definitions:
- TotalReviews: Number of non-null review scores.
- ReviewPercentage: Percentage of scored reviews for each rating.
- PositiveReviews: Reviews with scores of 4 or 5.
- NegativeReviews: Reviews with scores of 1 or 2.

Note:
Reviews with a null score are excluded from the analysis.
A review score is a measure of customer feedback, not necessarily
a direct measure of product quality.
*/

WITH ReviewSummary AS
(
    SELECT
        review_score AS ReviewScore,
        COUNT(*) AS ReviewCount
    FROM staging.order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY review_score
),
ReviewDistribution AS
(
    SELECT
        ReviewScore,
        ReviewCount,
        CAST(
            ReviewCount * 100.0
            / NULLIF(SUM(ReviewCount) OVER (), 0)
            AS DECIMAL(5, 2)
        ) AS ReviewPercentage
    FROM ReviewSummary
)
SELECT
    ReviewScore,
    ReviewCount,
    ReviewPercentage,
    CASE
        WHEN ReviewScore IN (4, 5) THEN 'Positive'
        WHEN ReviewScore IN (1, 2) THEN 'Negative'
        WHEN ReviewScore = 3 THEN 'Neutral'
        ELSE 'Other'
    END AS ReviewCategory
FROM ReviewDistribution
ORDER BY ReviewScore DESC;
GO

-- Overall positive and negative review summary
SELECT
    COUNT(*) AS TotalReviews,
    SUM(CASE WHEN review_score IN (4, 5) THEN 1 ELSE 0 END)
        AS PositiveReviews,
    SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END)
        AS NegativeReviews,
    SUM(CASE WHEN review_score = 3 THEN 1 ELSE 0 END)
        AS NeutralReviews,
    CAST(
        100.0 * SUM(CASE WHEN review_score IN (4, 5) THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS PositiveReviewPercentage,
    CAST(
        100.0 * SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS NegativeReviewPercentage
FROM staging.order_reviews
WHERE review_score IS NOT NULL;
GO