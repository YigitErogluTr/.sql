/*
  Monthly Expense Breakdown by Account Group
  - Groups by year and month
  - Calculates net (Debit - Credit) for each account group
*/

SELECT
    YEAR(H.[RefDate])  AS [Year],
    MONTH(H.[RefDate]) AS [Month],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '710'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC710 - Direct Material],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '720'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC720 - Direct Labor],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '730'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC730 - Manufacturing Overhead],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '740'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC740 - Service Production Cost],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '750'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC750 - Marketing Expenses],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '760'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC760 - General Admin Expenses],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '770'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC770 - Depreciation & Financing],

    SUM(CASE WHEN LEFT(L.[Account], 3) = '780'
             THEN L.[Debit] - L.[Credit] ELSE 0 END) AS [ACC780 - Financing Expenses]

FROM dbo.OJDT AS H
INNER JOIN dbo.JDT1 AS L
        ON H.[TransId] = L.[TransId]
WHERE
    YEAR(H.[RefDate]) = 2025
    AND LEFT(L.[Account], 3) IN ('710','720','730','740','750','760','770','780')
GROUP BY
    YEAR(H.[RefDate]),
    MONTH(H.[RefDate])
ORDER BY
    YEAR(H.[RefDate]),
    MONTH(H.[RefDate]);
