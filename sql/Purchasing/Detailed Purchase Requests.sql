/*
  Purchase Requests - Header + Lines
  - Shows request status, requester, dates, item, open qty, warehouse, notes
  - Safe/clean aliases for public repositories
*/

SELECT
    H.[DocStatus]        AS [RequestStatus],
    H.[ReqName]          AS [RequestedBy],
    H.[DocNum]           AS [RequestNumber],
    H.[DocDueDate]       AS [RequiredDate],
    H.[TaxDate]          AS [DocumentDate],

    L.[ItemCode]         AS [ItemCode],
    L.[Dscription]       AS [ItemDescription],
    L.[Quantity]         AS [Quantity],
    L.[OpenCreQty]       AS [OpenQuantity],
    L.[WhsCode]          AS [WarehouseCode],

    H.[Comments]         AS [HeaderComments],
    L.[Text]             AS [LineNotes]
FROM dbo.PRQ1 AS L        -- Purchase Request Lines
INNER JOIN dbo.OPRQ AS H   -- Purchase Request Header
        ON H.[DocEntry] = L.[DocEntry]
-- WHERE H.[DocStatus] = 'O'   -- uncomment to show only OPEN requests
ORDER BY
    H.[DocNum],
    L.[LineNum];
