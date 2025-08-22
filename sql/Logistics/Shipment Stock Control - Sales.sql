/*
  Open Sales Orders vs. Warehouse Stock
  - Shows whether available stock is sufficient to cover open sales order lines
  - Excludes non-inventory items
*/

SELECT
    H.DocDueDate       AS [DueDate],
    H.TaxDate          AS [DocumentDate],
    H.DocEntry         AS [OrderNo],
    H.CardName         AS [CustomerName],

    L.ItemCode         AS [ItemCode],
    I.ItemName         AS [ItemName],
    L.WhsCode          AS [WarehouseCode],

    L.Quantity         AS [OrderQty],
    W.OnHand           AS [StockOnHand],
    (W.OnHand - L.Quantity) AS [AvailableAfterOrder],

    CASE
        WHEN W.OnHand - L.Quantity >= 0 THEN 'STOCK SUFFICIENT'
        ELSE 'STOCK INSUFFICIENT'
    END AS [StockStatus]

FROM ORDR AS H
INNER JOIN RDR1 AS L ON H.DocEntry = L.DocEntry
INNER JOIN OITM AS I ON L.ItemCode = I.ItemCode
INNER JOIN OITW AS W ON L.ItemCode = W.ItemCode
                    AND L.WhsCode = W.WhsCode

WHERE H.DocStatus = 'O'        -- Only Open orders
  AND I.InvntItem = 'Y'        -- Inventory items only

ORDER BY H.DocEntry;
