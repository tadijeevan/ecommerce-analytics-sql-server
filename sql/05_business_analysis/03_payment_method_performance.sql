USE EcommerceAnalytics;
GO

/*
Analysis: Payment Method Performance

Business questions:
1. Which payment methods generate the highest payment value?
2. How many payment records exist for each payment method?
3. What is the average payment value for each method?
4. What percentage of total payment value comes from each method?

Metric definitions:
- TotalPaymentValue = SUM of payment values.
- AveragePaymentValue = Average value per payment record.
- PaymentContributionPercentage = Payment method value / total payment value * 100.

Note:
Payment records are counted individually. An order may contain multiple
payment records, so payment record counts are not the same as order counts.
*/

WITH PaymentSummary AS
(
    SELECT
        payment_type,
        COUNT(*) AS PaymentRecordCount,
        CAST(SUM(payment_value) AS DECIMAL(18, 2)) AS TotalPaymentValue,
        CAST(AVG(payment_value) AS DECIMAL(18, 2)) AS AveragePaymentValue
    FROM staging.order_payments
    GROUP BY payment_type
)
SELECT
    payment_type AS PaymentMethod,
    PaymentRecordCount,
    TotalPaymentValue,
    AveragePaymentValue,
    CAST(
        TotalPaymentValue * 100.0
        / NULLIF(SUM(TotalPaymentValue) OVER (), 0)
        AS DECIMAL(5, 2)
    ) AS PaymentContributionPercentage
FROM PaymentSummary
ORDER BY TotalPaymentValue DESC;
GO