/*
  Purchase Goods Receipt - User & Buyer & PO Open Qty
  ---------------------------------------------------
  - Header: OPDN (Goods Receipt PO)
  - Lines : PDN1
  - Users : OUSR  (creator of GRN)
  - Buyer : OSLP  (linked on OPDN.SlpCode)
  - PO    : OPOR (header), POR1 (lines)  <-- to get OpenQty on the base PO line

  Notes:
  * Join to the base Purchase Order line via PDN1.BaseType=22, BaseEntry=POR1.DocEntry, BaseLine=POR1.LineNum.
  * Warehouse filter is parameterized (@Whs1, @Whs2). Replace or add more as needed.
*/

SELECT
    H.DocEntry             AS [GRNEntry],
    H.DocDate              AS [GRNDate],
    H.CardCode             AS [SupplierCode],
    H.CardName             AS [SupplierName],

    L.ItemCode             AS [ItemCode],
    L.Dscription           AS [ItemDescription],
    L.Quantity             AS [GRNQuantity],
    L.UnitMsr              AS [GRNUoM],
    L.WhsCode              AS [WarehouseCode],

    -- Base PO info (if GRN is based on a PO)
    PO.DocNum              AS [PONumber],
    PO.DocEntry            AS [POEntry],
    POL.OpenQty            AS [POOpenQuantity],

    -- GRN creator (user) and buyer
    U.USER_CODE            AS [CreatedByUserCode],
    U.U_NAME               AS [CreatedByUserName],
    SLP.SlpName            AS [BuyerName]

FROM dbo.OPDN AS H
INNER JOIN dbo.PDN1 AS L
        ON H.DocEntry = L.DocEntry
INNER JOIN dbo.OUSR AS U
        ON H.UserSign = U.USERID
INNER JOIN dbo.OSLP AS SLP
        ON H.SlpCode = SLP.SlpCode

-- Correct base-PO linkage for open quantity:
LEFT JOIN dbo.POR1 AS POL
       ON L.BaseType = 22
      AND L.BaseEntry = POL.DocEntry
      AND L.BaseLine  = POL.LineNum
LEFT JOIN dbo.OPOR AS PO
       ON PO.DocEntry = POL.DocEntry

WHERE
    H.CANCELED <> 'Y'
    AND L.WhsCode IN (@Whs1, @Whs2)   -- e.g. @Whs1 = 'WH1', @Whs2 = 'WH2'
ORDER BY
    H.DocDate DESC, H.DocEntry, L.LineNum;
