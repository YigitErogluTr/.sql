/*
  Projected Cash Inflow by Month & Year (from open sales orders)
  - Based on due date + payment terms extra days
  - Safe for public repos (no sensitive info)
*/

SELECT
    YEAR(DATEADD(DAY, ISNULL(PaymentTerms.ExtraDays, 0), SO.DocDueDate))   AS [Year],
    MONTH(DATEADD(DAY, ISNULL(PaymentTerms.ExtraDays, 0), SO.DocDueDate))  AS [Month],
    SUM(SO.DocTotal)                                                       AS [ProjectedCashInflow]
FROM dbo.ORDR AS SO
LEFT JOIN dbo.OCTG AS PaymentTerms
       ON SO.GroupNum = PaymentTerms.GroupNum   -- link to payment terms
WHERE SO.DocStatus = 'O'   -- only open sales orders
GROUP BY
    YEAR(DATEADD(DAY, ISNULL(PaymentTerms.ExtraDays, 0), SO.DocDueDate)),
    MONTH(DATEADD(DAY, ISNULL(PaymentTerms.ExtraDays, 0), SO.DocDueDate))
ORDER BY
    [Year], [Month];
