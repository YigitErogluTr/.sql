-- Return Reasons Distribution (Sales Returns)
-- Tables: ORDN (Return - Header) + RDN1 (Return - Rows) + ORER (Return Reasons master)
-- Notes:
--  - Counts lines grouped by normalized return reason.
--  - 'No Reason Entered' when ReturnRsn = -1.
--  - Excludes canceled documents.

SELECT 
    CASE 
        WHEN T1.[ReturnRsn] = -1 THEN N'No Reason Entered'
        ELSE T2.[Reason]
    END AS [Return Reason],
    COUNT(*) AS [Count]
FROM [dbo].[ORDN] AS T0
INNER JOIN [dbo].[RDN1] AS T1 
    ON T0.[DocEntry] = T1.[DocEntry]
LEFT JOIN [dbo].[ORER] AS T2 
    ON T1.[ReturnRsn] = T2.[AbsEntry]
WHERE T0.[CANCELED] = 'N'
GROUP BY 
    CASE 
        WHEN T1.[ReturnRsn] = -1 THEN N'No Reason Entered'
        ELSE T2.[Reason]
    END
ORDER BY [Count] DESC;
