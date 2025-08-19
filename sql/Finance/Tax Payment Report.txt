/*
  Monthly Debit / Credit Summary (by Selected Account Patterns)
  - Safe for public repos: account codes are provided via parameterized pattern list
  - Aggregates by Year + Month to avoid cross-year collisions
*/

-- 1) Provide your account code patterns here (ANONYMIZED EXAMPLE VALUES)
DECLARE @AccountPatterns TABLE (Pattern NVARCHAR(50) NOT NULL);
INSERT INTO @AccountPatterns (Pattern)
VALUES
    (N'ACC360%'),           -- e.g., replace with '360%' in private env
    (N'ACC361%'),           -- e.g., replace with '361%'
    (N'ACC770%'),           -- e.g., replace with '770%'
    (N'ACC7707%'),
    (N'ACC770%'),
    (N'ACC770%'),
    (N'ACC689%'),
    (N'ACC7689%');

SELECT
    YEAR(H.[TaxDate])  AS [Year],
    MONTH(H.[TaxDate]) AS [Month],
    L.[Account]        AS [AccountCode],
    A.[AcctName]       AS [AccountName],
    A.[ActCurr]        AS [AccountCurrency],
    SUM(L.[Debit])     AS [MonthlyTotalDebit],
    SUM(L.[Credit])    AS [MonthlyTotalCredit]
FROM dbo.OJDT AS H
INNER JOIN dbo.JDT1 AS L
        ON H.[TransId] = L.[TransId]
INNER JOIN dbo.OACT AS A
        ON L.[Account] = A.[AcctCode]
WHERE EXISTS (
    SELECT 1
    FROM @AccountPatterns P
    WHERE L.[Account] LIKE P.Pattern
)
GROUP BY
    YEAR(H.[TaxDate]),
    MONTH(H.[TaxDate]),
    L.[Account],
    A.[AcctName],
    A.[ActCurr]
ORDER BY
    [Year],
    [Month],
    [AccountCode];
