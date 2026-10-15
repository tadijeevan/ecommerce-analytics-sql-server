USE EcommerceAnalytics;
GO

/*
Analysis: Customer Review Scores and Product Category Performance

Business questions:
1. How are customer reviews distributed across scores from 1 to 5?
2. What percentage of reviews does each score represent?
3. What proportion of reviews are positive?
4. What proportion of reviews are negative?
5. Which product categories have the highest and lowest average
   customer review scores?
6. What percentage of reviews are positive or negative for each category?

Metric definitions:
- TotalReviews:
    Number of reviews with non-null review scores.

- PositiveReviews:
    Reviews with scores of 4 or 5.

- NegativeReviews:
    Reviews with scores of 1 or 2.

- NeutralReviews:
    Reviews with a score of 3.

- AverageReviewScore:
    Average score associated with each product category.

- PositiveReviewPercentage:
    Percentage of category-review associations with scores of 4 or 5.

- NegativeReviewPercentage:
    Percentage of category-review associations with scores of 1 or 2.

Scope and limitations:
- Reviews with null scores are excluded.
- An order can contain products from multiple categories.
- An order-level review may therefore be associated with multiple
  product categories.
- Category review counts represent order-review-category associations,
  not necessarily unique reviews across all categories.
- Including order_id prevents the same review_id associated with
  different orders from being incorrectly collapsed.
- A review score measures customer feedback, not necessarily
  objective product quality.
*/

------------------------------------------------------------
-- 1. Overall review-score distribution
------------------------------------------------------------

;WITH ReviewSummary AS
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
            100.0 * ReviewCount
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

------------------------------------------------------------
-- 2. Overall positive, negative, and neutral review summary
------------------------------------------------------------

SELECT
    COUNT(*) AS TotalReviews,

    SUM(
        CASE
            WHEN review_score IN (4, 5) THEN 1
            ELSE 0
        END
    ) AS PositiveReviews,

    SUM(
        CASE
            WHEN review_score IN (1, 2) THEN 1
            ELSE 0
        END
    ) AS NegativeReviews,

    SUM(
        CASE
            WHEN review_score = 3 THEN 1
            ELSE 0
        END
    ) AS NeutralReviews,

    CAST(
        100.0 * SUM(
            CASE
                WHEN review_score IN (4, 5) THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS PositiveReviewPercentage,

    CAST(
        100.0 * SUM(
            CASE
                WHEN review_score IN (1, 2) THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS NegativeReviewPercentage,

    CAST(
        100.0 * SUM(
            CASE
                WHEN review_score = 3 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS NeutralReviewPercentage

FROM staging.order_reviews
WHERE review_score IS NOT NULL;
GO

------------------------------------------------------------
-- 3. Customer review scores by product category
------------------------------------------------------------

;WITH CategoryReviewDetails AS
(
    SELECT DISTINCT
        o.order_id,
        p.product_category_name,
        r.review_id,
        r.review_score
    FROM staging.orders AS o

    INNER JOIN staging.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN staging.products AS p
        ON oi.product_id = p.product_id

    INNER JOIN staging.order_reviews AS r
        ON o.order_id = r.order_id

    WHERE r.review_score IS NOT NULL
),
CategoryReviewSummary AS
(
    SELECT
        product_category_name,

        COUNT(*) AS CategoryReviewCount,

        CAST(
            AVG(CAST(review_score AS DECIMAL(5, 2)))
            AS DECIMAL(5, 2)
        ) AS AverageReviewScore,

        SUM(
            CASE WHEN review_score = 1 THEN 1 ELSE 0 END
        ) AS OneStarReviews,

        SUM(
            CASE WHEN review_score = 2 THEN 1 ELSE 0 END
        ) AS TwoStarReviews,

        SUM(
            CASE WHEN review_score = 3 THEN 1 ELSE 0 END
        ) AS ThreeStarReviews,

        SUM(
            CASE WHEN review_score = 4 THEN 1 ELSE 0 END
        ) AS FourStarReviews,

        SUM(
            CASE WHEN review_score = 5 THEN 1 ELSE 0 END
        ) AS FiveStarReviews,

        SUM(
            CASE
                WHEN review_score IN (1, 2) THEN 1
                ELSE 0
            END
        ) AS NegativeReviews,

        SUM(
            CASE
                WHEN review_score IN (4, 5) THEN 1
                ELSE 0
            END
        ) AS PositiveReviews

    FROM CategoryReviewDetails
    GROUP BY product_category_name
)
SELECT
    COALESCE(
        product_category_name,
        'Unknown Category'
    ) AS ProductCategory,

    CategoryReviewCount,
    AverageReviewScore,

    OneStarReviews,
    TwoStarReviews,
    ThreeStarReviews,
    FourStarReviews,
    FiveStarReviews,

    NegativeReviews,
    PositiveReviews,

    CAST(
        100.0 * NegativeReviews
        / NULLIF(CategoryReviewCount, 0)
        AS DECIMAL(5, 2)
    ) AS NegativeReviewPercentage,

    CAST(
        100.0 * PositiveReviews
        / NULLIF(CategoryReviewCount, 0)
        AS DECIMAL(5, 2)
    ) AS PositiveReviewPercentage

FROM CategoryReviewSummary
ORDER BY
    AverageReviewScore DESC,
    CategoryReviewCount DESC;
GO