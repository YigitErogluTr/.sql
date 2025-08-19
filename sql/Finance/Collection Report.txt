/*
  Incoming Payments (Active Only)
  - Lists payment documents and related details
  - Safe, anonymized version for public repositories
*/

SELECT
    P.[DocNum]         AS [DocumentNumber],
    P.[DocType]        AS [DocumentType],
    P.[Canceled]       AS [IsCanceled],
    P.[TaxDate]        AS [PostingDate],
    P.[CardCode]       AS [BusinessPartnerCode],
    P.[CardName]       AS [BusinessPartnerName],
    P.[DocRate]        AS [ExchangeRate],
    P.[DocCurr]        AS [Currency],
    P.[TrsfrAcct]      AS [TransferAccount],
    P.[TrsfrSum]       AS [TransferAmount],
    P.[CheckAcct]      AS [CheckAccount],
    P.[CheckSum]       AS [CheckAmount],
    L.[DueDate]        AS [DueDate],
    P.[CashAcct]       AS [CashAccount],
    P.[CashSum]        AS [CashAmount],
    P.[CreditSum]      AS [CreditTotal],
    P.[Comments]       AS [Remarks]
FROM dbo.ORCT AS P
LEFT JOIN dbo.RCT1 AS L
       ON P.[DocNum] = L.[DocNum]
WHERE P.[Canceled] = 'N';   -- only active payments
