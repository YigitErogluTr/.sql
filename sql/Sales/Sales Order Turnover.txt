-- Sales Orders with line details, delivery status, due terms impact, and TRY-calculated amounts
SELECT
    so.DocEntry                               AS OrderEntryId,
    so.DocDate                                AS OrderCreatedOn,
    so.DocDueDate                             AS PlannedDeliveryDate,
    so.TaxDate                                AS DocumentDate,
    YEAR(so.TaxDate)                          AS DocumentYear,
    MONTH(so.TaxDate)                         AS DocumentMonth,
    so.DocStatus                              AS OrderStatus,
    so.CANCELED                               AS IsCanceled,
    so.GroupNum                               AS PaymentTermsCode,
    pt.ExtraDays                              AS PaymentTermExtraDays,
    DATEADD(DAY, pt.ExtraDays, so.DocDueDate) AS PlannedDueDate,

    -- Business partner
    so.CardCode                               AS BpCode,
    so.CardName                               AS BpName,
    bp.GroupCode                              AS BpGroupCode,
    bpg.GroupName                             AS BpGroupName,

    -- Ship-to (fallback text anonymized/English)
    CASE WHEN ISNULL(so.ShipToCode, '') <> '' THEN so.ShipToCode
         ELSE 'SHIP_TO_BILLING_ADDRESS'
    END                                        AS ShipToCode,
    so.Address2                                AS ShipToAddress,

    -- Custom fields (kept as-is, neutral English aliases)
    so.U_AIF_ET_OrderNo                        AS ExternalOrderNo,
    so.U_H1_eIrsaliyeNo                        AS EDispatchNo,
    so.U_H1_BelgeTipi                          AS SalesDocType,

    -- Sales employee
    so.SlpCode                                 AS SalesEmployeeCode,
    se.SlpName                                 AS SalesEmployeeName,

    -- Item / warehouse
    sol.WhsCode                                AS WarehouseCode,
    it.ItmsGrpCod                              AS ItemGroupCode,
    ig.ItmsGrpNam                              AS ItemGroupName,
    it.U_stokkodgrup                           AS ItemCodeGroup,
    sol.ItemCode                               AS ItemCode,
    sol.Dscription                             AS ItemDescription,

    -- Quantities
    sol.Quantity                               AS OrderQty,
    sol.DelivrdQty                             AS DeliveredQty,

    -- UoM and pricing
    sol.UomCode                                AS UomCode,
    sol.PriceBefDi                             AS UnitPrice,
    so.DocCur                                  AS DocumentCurrency,
    sol.Rate                                   AS FxRate,

    -- TRY-calculated amounts (tax excluded)
    CASE
        WHEN sol.Rate = 0 OR sol.Rate IS NULL THEN sol.PriceBefDi
        ELSE sol.PriceBefDi * sol.Rate
    END                                         AS UnitPriceTRY,

    sol.Quantity *
    CASE
        WHEN sol.Rate = 0 OR sol.Rate IS NULL THEN sol.PriceBefDi
        ELSE sol.PriceBefDi * sol.Rate
    END                                         AS LineTotalTRY_ExclVat,

    sol.DelivrdQty *
    CASE
        WHEN sol.Rate = 0 OR sol.Rate IS NULL THEN sol.PriceBefDi
        ELSE sol.PriceBefDi * sol.Rate
    END                                         AS DeliveredTotalTRY_ExclVat,

    -- VAT
    sol.VatGroup                               AS VatCode,
    CASE sol.VatGroup
        WHEN 's05' THEN '0%'
        WHEN 's19' THEN '20%'
        WHEN 's20' THEN '10%'
        WHEN 's21' THEN '20%'
        WHEN 'S04' THEN '0%'
        WHEN 'S12' THEN '18%'
        WHEN 'S22' THEN '10%'
        WHEN 'S23' THEN '20%'
        WHEN 'S24' THEN '10%'
        ELSE ''
    END                                         AS VatRateText
FROM
    RDR1  AS sol
    INNER JOIN ORDR  AS so   ON so.DocEntry = sol.DocEntry
    INNER JOIN OCRD  AS bp   ON so.CardCode = bp.CardCode
    INNER JOIN OCRG  AS bpg  ON bp.GroupCode = bpg.GroupCode
    INNER JOIN OSLP  AS se   ON so.SlpCode  = se.SlpCode
    INNER JOIN OITM  AS it   ON sol.ItemCode = it.ItemCode
    INNER JOIN OITB  AS ig   ON it.ItmsGrpCod = ig.ItmsGrpCod
    INNER JOIN OCTG  AS pt   ON so.GroupNum = pt.GroupNum
WHERE
    so.CANCELED = 'N'
ORDER BY
    so.DocEntry;
