/*
  Standard Cost vs Actual Account Balances
  ----------------------------------------
  - Filters transactions for accounts starting with '373'
  - Compares balances against standard cost counterpart accounts
  - Allows filtering by date range parameters (@StartDate, @EndDate)
*/

DECLARE @StartDate DATE;
DECLARE @EndDate   DATE;

-- Dynamic Date Parameters (replace with actual values if needed)
SET @StartDate = /* Header.RefDate */ '[%0]';
SET @EndDate   = /* Header.RefDate */ '[%1]';

-- Example static dates for testing:
-- SET @StartDate = '2023-01-01';
-- SET @EndDate   = '2023-01-31';

SELECT  
    L.[Account]                                    AS [AccountCode],
    A.[AcctName]                                   AS [AccountName],
    L.[ProfitCode]                                 AS [ProfitCenterCode],
    PC.[OcrName]                                   AS [ProfitCenterName],

    SUM(L.[Debit])                                 AS [TotalDebit],
    SUM(L.[Credit])                                AS [TotalCredit],
    SUM(L.[Debit]) - SUM(L.[Credit])               AS [Balance],

    A.[U_STD_CostCounterAccount]                   AS [StandardCostCounterAccount],
    (
        SELECT SUM(X.[Debit]) - SUM(X.[Credit])
        FROM dbo.JDT1 X WITH(NOLOCK)
        WHERE X.[RefDate] BETWEEN @StartDate AND @EndDate
          AND X.[Account] = A.[U_STD_CostCounterAccount]
    ) AS [Balance_StdCostCounterAccount],

    A.[U_STD_CostGroupAccounts]                    AS [StandardCostGroupAccounts],
    (
        SELECT SUM(X.[Debit]) - SUM(X.[Credit])
        FROM dbo.JDT1 X WITH(NOLOCK)
        WHERE X.[RefDate] BETWEEN @StartDate AND @EndDate
          AND X.[Account] = A.[U_STD_CostGroupAccounts]
    ) AS [Balance_GroupAccounts]

FROM dbo.OJDT H WITH(NOLOCK)
INNER JOIN dbo.JDT1 L WITH(NOLOCK) ON H.[TransId] = L.[TransId]
INNER JOIN dbo.OACT A WITH(NOLOCK) ON L.[Account] = A.[AcctCode]
LEFT JOIN  dbo.OACT ACC1 WITH(NOLOCK) ON A.[U_STD_CostCounterAccount] = ACC1.[AcctCode]
LEFT JOIN  dbo.OACT ACC2 WITH(NOLOCK) ON A.[U_STD_CostGroupAccounts] = ACC2.[AcctCode]
LEFT JOIN  dbo.OACT PARENT WITH(NOLOCK) ON A.[FatherNum] = PARENT.[AcctCode]
LEFT JOIN  dbo.OOCR PC WITH(NOLOCK) ON L.[ProfitCode] = PC.[OcrCode] AND PC.[DimCode] = 1

WHERE 
    L.[Account] LIKE '373%'               -- Filter specific account group
    AND H.[RefDate] BETWEEN @StartDate AND @EndDate
    AND H.[TransType] NOT IN (60)         -- Exclude specific transaction types

GROUP BY 
    L.[Account], 
    A.[AcctName], 
    A.[U_STD_CostCounterAccount], 
    A.[U_STD_CostGroupAccounts], 
    L.[ProfitCode], 
    PC.[OcrName]

ORDER BY [AccountCode];

/* 
-- Optional: to filter specific TransTypes
-- AND H.[TransType] IN (1470000071)
*/
