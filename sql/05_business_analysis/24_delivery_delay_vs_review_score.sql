USE EcommerceAnalytics;
GO

/*
Analysis: Delivery Delay vs Customer Review Score

Business questions:
1. Do late deliveries tend to receive lower review scores?
2. How do average review scores differ between early,
   on-time, and late deliveries?
3. What percentage of reviews in each delivery group
   are negative?

Metric definitions:
- DeliveryVarianceDays:
    Actual delivery date minus estimated delivery date,
    measured in calendar-day boundaries using DATEDIFF.
- Early:
    DeliveryVarianceDays < 0.
- On Time:
    DeliveryVarianceDays = 0.
- Late:
    DeliveryVarianceDays > 0.
- NegativeReview:
    Review score of 1 or 2.
- PositiveReview:
    Review score of 4 or 5.
- NeutralReview:
    Review score of 3.

Scope and limitations:
- Only delivered orders with valid actual and estimated
  delivery timestamps and non-null review scores are included.
- Delivery groups use calendar-day boundaries, not exact
  timestamp equality.
- Review counts represent joined review records.
- The results show associations and do not establish causation.
*/

------------------------------------------------------------
-- 1. Average review score by delivery performance group
------------------------------------------------------------

;WITH DeliveryReviewDetails AS
(
    SELECT
        o.order_id AS OrderID,
        r.review_id AS ReviewID,
        r.review_score AS ReviewScore,

        DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) AS DeliveryVarianceDays,

        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) < 0
                THEN 'Early'

            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) = 0
                THEN 'On Time'

            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0
                THEN 'Late'
        END AS DeliveryPerformance

    FROM staging.orders AS o

    INNER JOIN staging.order_reviews AS r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND r.review_score IS NOT NULL
),
DeliveryReviewSummary AS
(
    SELECT
        DeliveryPerformance,

        COUNT(*) AS ReviewCount,

        CAST(
            AVG(CAST(ReviewScore AS DECIMAL(5, 2)))
            AS DECIMAL(5, 2)
        ) AS AverageReviewScore,

        SUM(
            CASE
                WHEN ReviewScore IN (1, 2) THEN 1
                ELSE 0
            END
        ) AS NegativeReviews,

        SUM(
            CASE
                WHEN ReviewScore IN (4, 5) THEN 1
                ELSE 0
            END
        ) AS PositiveReviews,

        SUM(
            CASE
                WHEN ReviewScore = 3 THEN 1
                ELSE 0
            END
        ) AS NeutralReviews

    FROM DeliveryReviewDetails
    GROUP BY DeliveryPerformance
)
SELECT
    DeliveryPerformance,
    ReviewCount,
    AverageReviewScore,
    NegativeReviews,
    PositiveReviews,
    NeutralReviews,

    CAST(
        100.0 * NegativeReviews
        / NULLIF(ReviewCount, 0)
        AS DECIMAL(5, 2)
    ) AS NegativeReviewPercentage,

    CAST(
        100.0 * PositiveReviews
        / NULLIF(ReviewCount, 0)
        AS DECIMAL(5, 2)
    ) AS PositiveReviewPercentage

FROM DeliveryReviewSummary
ORDER BY
    CASE DeliveryPerformance
        WHEN 'Early' THEN 1
        WHEN 'On Time' THEN 2
        WHEN 'Late' THEN 3
        ELSE 4
    END;
GO

------------------------------------------------------------
-- 2. Review score distribution by delivery performance
------------------------------------------------------------

;WITH DeliveryReviewDetails AS
(
    SELECT
        o.order_id AS OrderID,
        r.review_id AS ReviewID,
        r.review_score AS ReviewScore,

        DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) AS DeliveryVarianceDays,

        CASE
            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) < 0
                THEN 'Early'

            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) = 0
                THEN 'On Time'

            WHEN DATEDIFF(
                DAY,
                o.order_estimated_delivery_date,
                o.order_delivered_customer_date
            ) > 0
                THEN 'Late'
        END AS DeliveryPerformance

    FROM staging.orders AS o

    INNER JOIN staging.order_reviews AS r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND r.review_score IS NOT NULL
),
ReviewDistribution AS
(
    SELECT
        DeliveryPerformance,
        ReviewScore,
        COUNT(*) AS ReviewCount

    FROM DeliveryReviewDetails

    GROUP BY
        DeliveryPerformance,
        ReviewScore
)
SELECT
    DeliveryPerformance,
    ReviewScore,
    ReviewCount,

    CAST(
        100.0 * ReviewCount
        / NULLIF(
            SUM(ReviewCount) OVER (
                PARTITION BY DeliveryPerformance
            ),
            0
        )
        AS DECIMAL(5, 2)
    ) AS PercentageWithinDeliveryGroup

FROM ReviewDistribution

ORDER BY
    CASE DeliveryPerformance
        WHEN 'Early' THEN 1
        WHEN 'On Time' THEN 2
        WHEN 'Late' THEN 3
        ELSE 4
    END,
    ReviewScore DESC;
GO