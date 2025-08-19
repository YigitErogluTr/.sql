/*
  Projected Cash Inflow by Month & Year
  - Based on due date of open sales orders
  - Safe & generic version for public repositories
*/

SELECT
    YEAR(SO.DocDueDate)   AS [Year],
    MONTH(SO.DocDueDate)  AS [Month],
    SUM(SO.DocTotal)      AS [ProjectedCashInflow]
FROM dbo.ORDR AS SO
WHERE SO.DocStatus = 'O'   -- only open sales orders
GROUP BY
    YEAR(SO.DocDueDate),
    MONTH(SO.DocDueDate)
ORDER BY
    [Year],
    [Month];
