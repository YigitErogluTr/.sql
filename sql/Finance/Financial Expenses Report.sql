/*
  Monthly Debit / Credit Summary by Selected Accounts
  - Filters specific accounts by code patterns
  - Groups by account, account name, currency and month
*/

SELECT
    L.[Account]              AS [AccountCode],
    A.[AcctName]             AS [AccountName],
    A.[ActCurr]              AS [AccountCurrency],
    MONTH(H.[TaxDate])       AS [Month],
    SUM(L.[Debit])           AS [MonthlyTotalDebit],
    SUM(L.[Credit])          AS [MonthlyTotalCredit]
FROM dbo.OJDT AS H
INNER JOIN dbo.JDT1 AS L
        ON H.[TransId] = L.[TransId]
INNER JOIN dbo.OACT AS A
        ON L.[Account] = A.[AcctCode]
WHERE
    L.[Account] LIKE N'XXX-01-01-001%' OR
    L.[Account] LIKE N'YYY-01-01-002%' OR
    L.[Account] LIKE N'ABC%' OR
    L.[Account] LIKE N'DEF%' OR
    L.[Account] LIKE N'GHI%' OR
    L.[Account] LIKE N'JKL%'
GROUP BY
    L.[Account],
    A.[AcctName],
    A.[ActCurr],
    MONTH(H.[TaxDate]);
