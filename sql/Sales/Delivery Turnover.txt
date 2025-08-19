-- Delivery Notes with Linked Sales Order Quantities
-- DLN1/ODLN (Delivery) + RDR1 (Sales Order) + BP/Items/Groups/Salesperson
-- Notes:
--  - All column captions are English and generic.
--  - Local currency (LC) math uses PriceBefDi * Rate with NULL-safe handling.
--  - "Not Shipped Qty" = max(SO Qty - Delivered Qty, 0).

SELECT
    -- Dates & Document
    H.[DocDate]                       AS [Posting Date],
    H.[DocDueDate]                    AS [Due Date],
    H.[TaxDate]                       AS [Document Date],
    MONTH(H.[TaxDate])                AS [Document Month],
    H.[DocEntry]                      AS [Document No],
    H.[CANCELED]                      AS [Canceled],

    -- Business Partner
    H.[CardCode]                      AS [BP Code],
    H.[CardName]                      AS [BP Name],
    BP.[GroupCode]                    AS [BP Group Code],
    BPG.[GroupName]                   AS [BP Group Name],

    -- Shipping
    CASE WHEN ISNULL(H.[ShipToCode], '') <> '' THEN H.[ShipToCode]
         ELSE 'BILLING ADDRESS (SHIP-TO)'
    END                               AS [Ship-To Code],
    H.[Address2]                      AS [Ship-To Address],

    -- Custom references (kept as-is; generic captions)
    H.[U_AIF_ET_OrderNo]              AS [External Order No],
    H.[U_H1_eIrsaliyeNo]              AS [E-Dispatch No],
    H.[U_H1_BelgeTipi]                AS [Sales Doc Type],

    -- Sales employee
    H.[SlpCode]                       AS [Sales Employee Code],
    S.[SlpName]                       AS [Sales Employee],

    -- Item & groups
    L.[WhsCode]                       AS [Warehouse],
    I.[ItmsGrpCod]                    AS [Item Group Code],
    IG.[ItmsGrpNam]                   AS [Item Group Name],
    I.[U_stokkodgrup]                 AS [Item Code Group],

    L.[ItemCode]                      AS [Item Code],
    L.[Dscription]                    AS [Item Description],

    -- Quantities (Delivery + linked Sales Order)
    L.[Quantity]                      AS [Delivered Quantity],
    SO.[Quantity]                     AS [Sales Order Quantity],
    CASE WHEN ISNULL(SO.[Quantity], 0) - ISNULL(L.[Quantity], 0) > 0
         THEN ISNULL(SO.[Quantity], 0) - ISNULL(L.[Quantity], 0)
         ELSE 0
    END                               AS [Not Shipped Quantity],

    -- Pricing & currency
    L.[UomCode]                       AS [UoM],
    L.[PriceBefDi]                    AS [Unit Price (DocCur, excl. tax)],
    H.[DocCur]                        AS [Document Currency],
    L.[Rate]                          AS [Currency Rate],
    CASE
        WHEN ISNULL(L.[Rate], 0) = 0 THEN L.[PriceBefDi]
        ELSE L.[PriceBefDi] * L.[Rate]
    END                               AS [Unit Price (LC, excl. tax)],

    L.[Quantity] * CASE
        WHEN ISNULL(L.[Rate], 0) = 0 THEN L.[PriceBefDi]
        ELSE L.[PriceBefDi] * L.[Rate]
    END                               AS [Line Total (LC, excl. tax)],

    -- VAT
    L.[VatGroup]                      AS [VAT Code],
    CASE
        WHEN L.[VatGroup] = 's05' THEN '%0'

        ELSE ''
    END                                AS [VAT Rate]

FROM
    DLN1 L
    INNER JOIN ODLN H   ON H.[DocEntry]   = L.[DocEntry]
    INNER JOIN OCRD BP  ON H.[CardCode]   = BP.[CardCode]
    INNER JOIN OCRG BPG ON BP.[GroupCode] = BPG.[GroupCode]
    INNER JOIN OSLP S   ON H.[SlpCode]    = S.[SlpCode]
    INNER JOIN OITM I   ON L.[ItemCode]   = I.[ItemCode]
    INNER JOIN OITB IG  ON I.[ItmsGrpCod] = IG.[ItmsGrpCod]
    LEFT  JOIN RDR1 SO  ON L.[BaseEntry]  = SO.[DocEntry]
                        AND L.[BaseLine]  = SO.[LineNum]
                        AND L.[BaseType]  = 17  -- Sales Order

WHERE
    H.[CANCELED] = 'N';
