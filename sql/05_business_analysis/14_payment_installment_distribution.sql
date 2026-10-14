USE EcommerceAnalytics;
GO

/*
Purpose:
    Analyze the distribution of payment installments.

Business question:
    What is the distribution of payment installments?

Metrics:
    - Number of payment records per installment count
    - Total payment value per installment count
    - Percentage of payment records per installment count

Grain:
    One row per payment_installments value.

Source:
    staging.order_payments

Note:
    Percentages are based on payment records, not distinct orders.
*/

WITH InstallmentSummary AS (
    SELECT
        payment_installments,
        COUNT_BIG(*) AS PaymentRecordCount,
        SUM(payment_value) AS TotalPaymentValue
    FROM staging.order_payments
    GROUP BY payment_installments
)
SELECT
    payment_installments,
    PaymentRecordCount,
    TotalPaymentValue,
    CAST(
        100.0 * PaymentRecordCount
        / SUM(PaymentRecordCount) OVER ()
        AS DECIMAL(6, 2)
    ) AS PercentageOfPaymentRecords
FROM InstallmentSummary
ORDER BY payment_installments;