/*
  Monthly Debit / Credit Summary by Account
  - Filters accounts containing '309'
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
WHERE L.[Account] LIKE N'%309%'
GROUP BY
    L.[Account],
    A.[AcctName],
    A.[ActCurr],
    MONTH(H.[TaxDate]);
