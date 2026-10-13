CREATE OR ALTER VIEW reporting.vw_payment_performance
AS
SELECT
    op.payment_type AS PaymentType,
    COUNT(*) AS TotalPaymentRecords,
    COUNT(DISTINCT op.order_id) AS TotalOrders,
    CAST(SUM(op.payment_value) AS DECIMAL(18, 2)) AS TotalPaymentValue,
    CAST(AVG(op.payment_value) AS DECIMAL(18, 2)) AS AveragePaymentValue
FROM staging.order_payments AS op
INNER JOIN staging.orders AS o
    ON op.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    op.payment_type;
GO
