/* Purchasing — Supplier Analysis (Anonymized) */
SELECT
    GR.DocEntry                                            AS [Goods Receipt No],
    GR.DocDate                                             AS [Goods Receipt Date],
    PO.DocNum                                              AS [Purchase Order No],
    PO.DocDate                                             AS [PO Document Date],
    PO.DocDueDate                                          AS [Planned Receipt Date],

    -- e-Dispatch / e-Despatch Number (hashed for anonymization)
    CONVERT(varchar(64), HASHBYTES('SHA2_256', CAST(GR.U_H1_eIrsaliyeNo AS nvarchar(200))), 2)
                                                           AS [e-Dispatch No (Hashed)],

    PO.U_H1_BelgeTipiSA                                    AS [PO Document Type],

    -- Business Partner (hashed for anonymization)
    CONVERT(varchar(64), HASHBYTES('SHA2_256', CAST(PO.CardCode AS nvarchar(200))), 2)
                                                           AS [BP Code (Hashed)],
    CONVERT(varchar(64), HASHBYTES('SHA2_256', CAST(PO.CardName AS nvarchar(200))), 2)
                                                           AS [BP Name (Hashed)],

    -- Country info (kept as is)
    ADR.Country                                            AS [Country Code],
    CNT.Name                                               AS [Country Name],

    -- Buyer / Salesperson on PO (hashed for anonymization)
    CONVERT(varchar(64), HASHBYTES('SHA2_256', CAST(PO.SlpCode AS nvarchar(200))), 2)
                                                           AS [Buyer Code (Hashed)],
    CONVERT(varchar(64), HASHBYTES('SHA2_256', CAST(SLP.SlpName AS nvarchar(200))), 2)
                                                           AS [Buyer Name (Hashed)],

    ITB.ItmsGrpNam                                         AS [Item Group],
    ITM.U_stokkodgrup                                      AS [Product Group],

    GRL.ItemCode                                           AS [Item Code],
    GRL.Dscription                                         AS [Item Description],
    ITM.U_boyolcusu                                        AS [Thickness (MIC)],
    ITM.U_enolcusu                                         AS [Length (CM)],

    GRL.WhsCode                                            AS [Receipt Warehouse],
    GRL.VatGroup                                           AS [VAT Code],
    VAT.Rate                                               AS [VAT Rate],

    POL.Quantity                                           AS [PO Quantity],
    POL.InvQty                                             AS [PO Inventory UoM Quantity],
    POL.UomCode                                            AS [PO UoM],

    GRL.Quantity                                           AS [Receipt Quantity],
    GRL.InvQty                                             AS [Receipt Inventory UoM Quantity],
    GRL.UomCode                                            AS [Receipt UoM],

    POL.OpenQty                                            AS [Open Quantity],
    POL.UnitMsr                                            AS [PO Unit of Measure],

    PO.DocCur                                              AS [PO Document Currency],
    PO.DocRate                                             AS [PO Document Rate],
    POL.Rate                                               AS [PO Line Rate],
    GRL.Rate                                               AS [Receipt Line Rate],

    POL.Price                                              AS [PO Unit Price],
    GRL.Price                                              AS [Receipt Unit Price],

    POL.LineTotal                                          AS [PO Line Total (LC)],
    POL.TotalFrgn                                          AS [PO Line Total (FC)],
    POL.TotalSumSy                                         AS [PO Line Total (SC)],

    GRL.LineTotal                                          AS [Receipt Line Total (LC)],
    GRL.TotalFrgn                                          AS [Receipt Line Total (FC)],
    GRL.TotalSumSy                                         AS [Receipt Line Total (SC)],

    GRL.OpenSum                                            AS [Open Amount (LC)],
    GRL.OpenSumFC                                          AS [Open Amount (FC)],
    GRL.OpenSumSys                                         AS [Open Amount (SC)],

    GRL.VatSum                                             AS [Receipt VAT (LC)],
    GRL.VatSumFrgn                                         AS [Receipt VAT (FC)],
    GRL.VatSumSy                                           AS [Receipt VAT (SC)],

    PO.Comments                                            AS [PO Comments]

FROM OPDN AS GR
INNER JOIN PDN1 AS GRL
        ON GR.DocEntry = GRL.DocEntry
LEFT  JOIN POR1 AS POL
        ON GRL.BaseEntry = POL.DocEntry
       AND GRL.BaseType  = POL.ObjType
       AND GRL.ItemCode  = POL.ItemCode
LEFT  JOIN OPOR AS PO
        ON POL.DocEntry  = PO.DocEntry
INNER JOIN OCRD AS BP
        ON PO.CardCode   = BP.CardCode
INNER JOIN CRD1 AS ADR
        ON BP.CardCode   = ADR.CardCode
INNER JOIN OCRY AS CNT
        ON ADR.Country   = CNT.Code
LEFT  JOIN OITM AS ITM
        ON GRL.ItemCode  = ITM.ItemCode
LEFT  JOIN OITB AS ITB
        ON ITM.ItmsGrpCod = ITB.ItmsGrpCod
LEFT  JOIN OVTG AS VAT
        ON GRL.VatGroup  = VAT.Code
LEFT  JOIN OSLP AS SLP
        ON PO.SlpCode    = SLP.SlpCode

WHERE
    PO.CANCELED  <> 'Y'
    AND GR.CANCELED <> 'Y'
    AND PO.DocDate BETWEEN [%0] AND [%1]

ORDER BY
    GR.DocNum;
