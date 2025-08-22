/*
  Trial Balance (Selected Account Buckets)
  ----------------------------------------
  - Filters by date range (@StartDate, @EndDate)
  - Combines multiple account buckets with UNION ALL
  - Uses NET balance = SUM(Debit - Credit)
  - Safe for public repos; account code ranges shown as examples

  Buckets:
    1) Accounts starting with: 600, 601, 620, 623
    2) Accounts starting with: 8
    3) Accounts starting with: 15 (excluding 158 and 159)
    4) Account prefix (3 digits) IN: 710, 711, 720, 721, 730, 731 (group by prefix)
    5) Accounts starting with: 373
*/

DECLARE @StartDate DATE;
DECLARE @EndDate   DATE;

-- Parameters (replace placeholders as needed)
SET @StartDate = /* Header.RefDate */ '[%0]';
SET @EndDate   = /* Header.RefDate */ '[%1]';

WITH
Bucket1 AS (
    SELECT
        L.[Account]                              AS [AccountCode],
        A.[AcctName]                             AS [AccountName],
        SUM(L.[Debit] - L.[Credit])              AS [Balance]
    FROM dbo.JDT1 AS L WITH (NOLOCK)
    LEFT JOIN dbo.OACT AS A WITH (NOLOCK) ON L.[Account] = A.[AcctCode]
    WHERE L.[RefDate] BETWEEN @StartDate AND @EndDate
      AND SUBSTRING(L.[Account], 1, 3) IN ('600','601','620','623')
    GROUP BY L.[Account], A.[AcctName]
),
Bucket2 AS (
    SELECT
        L.[Account]                              AS [AccountCode],
        A.[AcctName]                             AS [AccountName],
        SUM(L.[Debit] - L.[Credit])              AS [Balance]
    FROM dbo.JDT1 AS L WITH (NOLOCK)
    LEFT JOIN dbo.OACT AS A WITH (NOLOCK) ON L.[Account] = A.[AcctCode]
    WHERE L.[RefDate] BETWEEN @StartDate AND @EndDate
      AND L.[Account] LIKE '8%'
    GROUP BY L.[Account], A.[AcctName]
),
Bucket3 AS (
    SELECT
        L.[Account]                              AS [AccountCode],
        A.[AcctName]                             AS [AccountName],
        SUM(L.[Debit] - L.[Credit])              AS [Balance]
    FROM dbo.JDT1 AS L WITH (NOLOCK)
    LEFT JOIN dbo.OACT AS A WITH (NOLOCK) ON L.[Account] = A.[AcctCode]
    WHERE L.[RefDate] BETWEEN @StartDate AND @EndDate
      AND L.[Account] LIKE '15%'
      AND L.[Account] NOT LIKE '158%'
      AND L.[Account] NOT LIKE '159%'
    GROUP BY L.[Account], A.[AcctName]
),
Bucket4 AS (
    SELECT
        SUBSTRING(L.[Account], 1, 3)             AS [AccountCode],   -- 3-digit prefix
        A3.[AcctName]                            AS [AccountName],
        SUM(L.[Debit] - L.[Credit])              AS [Balance]
    FROM dbo.JDT1 AS L WITH (NOLOCK)
    LEFT JOIN dbo.OACT AS A3 WITH (NOLOCK)
           ON SUBSTRING(L.[Account], 1, 3) = A3.[AcctCode]
    WHERE L.[RefDate] BETWEEN @StartDate AND @EndDate
      AND SUBSTRING(L.[Account], 1, 3) IN ('710','711','720','721','730','731')
    GROUP BY SUBSTRING(L.[Account], 1, 3), A3.[AcctName]
),
Bucket5 AS (
    SELECT
        L.[Account]                              AS [AccountCode],
        A.[AcctName]                             AS [AccountName],
        SUM(L.[Debit] - L.[Credit])              AS [Balance]
    FROM dbo.JDT1 AS L WITH (NOLOCK)
    LEFT JOIN dbo.OACT AS A WITH (NOLOCK) ON L.[Account] = A.[AcctCode]
    WHERE L.[RefDate] BETWEEN @StartDate AND @EndDate
      AND L.[Account] LIKE '373%'
    GROUP BY L.[Account], A.[AcctName]
)

SELECT * FROM (
    SELECT * FROM Bucket1
    UNION ALL
    SELECT * FROM Bucket2
    UNION ALL
    SELECT * FROM Bucket3
    UNION ALL
    SELECT * FROM Bucket4
    UNION ALL
    SELECT * FROM Bucket5
) AS X
ORDER BY [AccountCode];
