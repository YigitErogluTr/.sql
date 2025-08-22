/*
  Stock Transfer Requests vs. Warehouse Stock
  - Shows whether available stock is sufficient to cover open transfer requests
  - Excludes non-inventory items
*/

SELECT
    H.[DocDueDate]                 AS [DueDate],
    H.[TaxDate]                    AS [DocumentDate],
    H.[DocEntry]                   AS [RequestNo],
    H.[CardName]                   AS [RequesterName],   -- if used; may be empty in some setups

    L.[ItemCode]                   AS [ItemCode],
    I.[ItemName]                   AS [ItemName],
    L.[WhsCode]                    AS [WarehouseCode],

    L.[Quantity]                   AS [RequestedQty],
    W.[OnHand]                     AS [StockOnHand],
    (W.[OnHand] - L.[Quantity])    AS [AvailableAfterRequest],

    CASE
        WHEN W.[OnHand] - L.[Quantity] >= 0 THEN 'STOCK SUFFICIENT'
        ELSE 'STOCK INSUFFICIENT'
    END                            AS [StockStatus]

FROM dbo.OWTQ AS H              -- Stock Transfer Request (header)
INNER JOIN dbo.WTQ1 AS L ON H.[DocEntry] = L.[DocEntry]     -- Request lines
INNER JOIN dbo.OITM AS I ON L.[ItemCode] = I.[ItemCode]     -- Item master
INNER JOIN dbo.OITW AS W ON L.[ItemCode] = W.[ItemCode]     -- Warehouse stock
                       AND L.[WhsCode]  = W.[WhsCode]

WHERE
    H.[DocStatus] = 'O'           -- Open requests only
    AND I.[InvntItem] = 'Y'       -- Inventory items only

ORDER BY
    H.[DocEntry];
