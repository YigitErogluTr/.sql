/*
  Last Purchased Items (Goods Receipt Lines)
  ------------------------------------------
  - Header: OPDN (Goods Receipt PO)
  - Lines : PDN1
  - Optional base doc (PO): OPOR
  - Optional target doc (AP Invoice): OPCH
  - Users: OUSR (for creator names)

  Notes:
  * Stock-unit unit cost is computed as:
      (GRN Quantity * GRN Unit Price * FX Rate to Local)
      / Inventory Quantity
  * FX rate logic: if Currency = 'TRY' (local), use 1, else use PDN1.Rate.
  * Column aliases are neutral/English for public repositories.
*/

SELECT
    L.ItemCode                       AS [ItemCode],
    L.Dscription                     AS [ItemDescription],
    H.CardName                       AS [SupplierName],

    L.Quantity                       AS [GRNQuantity],
    L.UomCode                        AS [GRNUoM],
    L.Price                          AS [GRNUnitPrice],

    L.InvQty                         AS [InventoryQty],
    L.UomCode2                       AS [InventoryUoM],

    -- Computed unit cost in stock (inventory) UoM, in local currency
    CAST(
        (
          CAST(L.Quantity AS DECIMAL(38,8)) *
          CAST(L.Price    AS DECIMAL(38,8)) *
          CAST(CASE WHEN L.Currency = 'TRY' THEN 1 ELSE L.Rate END AS DECIMAL(38,8))
        )
        / NULLIF(CAST(L.InvQty AS DECIMAL(38,8)), 0)
      AS DECIMAL(18,6)
    )                                 AS [UnitCostInInventoryUoM],

    L.Currency                        AS [Currency],
    L.Rate                            AS [FxRate],

    H.DocDate                         AS [GRNDate],
    H.DocEntry                        AS [GRNEntry],

    -- Base document (from which GRN is created)
    CASE
        WHEN L.BaseType = 22 THEN 'Purchase Order'
        ELSE CAST(L.BaseType AS VARCHAR(20))
    END                               AS [BaseDocType],
    L.BaseEntry                       AS [BaseDocEntry],

    U_GRN.U_NAME                      AS [CreatedBy_GRN],
    U_BASE.U_NAME                     AS [CreatedBy_BaseDoc],

    -- Target document (created from GRN line)
    CASE
        WHEN L.TargetType = 18 THEN 'AP Invoice'
        WHEN L.TargetType = 21 THEN 'Goods Return'
        WHEN L.TargetType = 234000032 THEN 'Return Request'
        ELSE CAST(L.TargetType AS VARCHAR(20))
    END                               AS [TargetDocType],
    L.TrgetEntry                      AS [TargetDocEntry],

    AP.NumAtCard                      AS [SupplierInvoiceRef]

FROM dbo.OPDN AS H
INNER JOIN dbo.PDN1 AS L
        ON H.DocEntry = L.DocEntry
INNER JOIN dbo.OUSR AS U_GRN
        ON H.UserSign = U_GRN.USERID

LEFT  JOIN dbo.OPOR AS PO
        ON L.BaseType = 22
       AND L.BaseEntry = PO.DocEntry
LEFT  JOIN dbo.OUSR AS U_BASE
        ON PO.UserSign = U_BASE.USERID

LEFT  JOIN dbo.OPCH AS AP
        ON L.TargetType = 18
       AND L.TrgetEntry = AP.DocEntry

WHERE H.CANCELED = 'N'
ORDER BY H.DocDate DESC;
