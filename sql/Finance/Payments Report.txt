/*
  Outgoing Payments (Active Only)
  - Lists vendor payments and related details
  - Safe, tidy version for public repositories
*/

SELECT
    P.[DocNum]      AS [DocumentNumber],
    P.[DocType]     AS [DocumentType],
    P.[Canceled]    AS [IsCanceled],
    P.[TaxDate]     AS [PostingDate],
    P.[CardCode]    AS [BusinessPartnerCode],
    P.[CardName]    AS [BusinessPartnerName],
    P.[DocRate]     AS [ExchangeRate],
    P.[DocCurr]     AS [Currency],
    P.[TrsfrAcct]   AS [TransferAccount],
    P.[TrsfrSum]    AS [TransferAmount],
    P.[CheckAcct]   AS [CheckAccount],
    P.[CheckSum]    AS [CheckAmount],
    L.[DueDate]     AS [DueDate],
    P.[CashAcct]    AS [CashAccount],
    P.[CashSum]     AS [CashAmount],
    P.[CreditSum]   AS [CreditTotal],
    P.[Comments]    AS [Remarks]
FROM dbo.OVPM AS P
LEFT JOIN dbo.VPM1 AS L
       ON P.[DocNum] = L.[DocNum]
WHERE P.[Canceled] = 'N';
