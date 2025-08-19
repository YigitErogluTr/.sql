-- Sales Quotations (header + lines) with line-level surcharge, VAT and totals
SELECT
    q.DocNum                                        AS QuoteNo,
    q.DocStatus                                     AS QuoteStatus,
    q.Printed                                       AS IsPrinted,
    q.DocDate                                       AS QuoteDate,
    q.DocDueDate                                    AS QuoteValidUntil,

    -- Business partner
    q.CardCode                                      AS BpCode,
    q.CardName                                      AS BpName,

    -- Contact (kept as generic fields, neutral aliases)
    q.U_AIF_ET_BuyerName                            AS ContactName,
    q.U_AIF_ET_BillPhone                            AS ContactPhone,

    -- Line items
    l.ItemCode                                      AS ItemCode,
    l.Dscription                                    AS ItemDescription,
    l.Quantity                                      AS Quantity,
    l.Price                                         AS UnitPrice,
    l.U_Klise_Bedel                                 AS LineSurcharge,     -- custom field (e.g., cliché fee)
    l.Rate                                          AS FxRate,

    -- Amounts (LC / system currency per SAP B1 semantics)
    l.LineTotal                                     AS LineAmount,
    (l.LineTotal + ISNULL(l.U_Klise_Bedel, 0))      AS LineAmountWithSurcharge,

    -- VAT
    l.VatPrcnt                                      AS VatPercent,
    (l.LineTotal + ISNULL(l.U_Klise_Bedel, 0)) * (ISNULL(l.VatPrcnt,0) / 100.0)
                                                     AS VatAmount,

    -- Grand total per line (tax included)
    (l.LineTotal + ISNULL(l.U_Klise_Bedel, 0))
      + (l.LineTotal + ISNULL(l.U_Klise_Bedel, 0)) * (ISNULL(l.VatPrcnt,0) / 100.0)
                                                     AS LineGrandTotal,

    -- Payment / shipping / sales rep
    pt.PymntGroup                                   AS PaymentTerm,
    q.Comments                                      AS HeaderRemarks,
    q.U_AIF_ET_OrderNo                              AS ExternalOrderNo,
    q.NumAtCard                                     AS BpReferenceNo,
    shp.TrnspName                                   AS ShippingMethod,
    rep.SlpName                                     AS SalesEmployeeName,

    -- Document type (custom)
    q.U_H1_BelgeTipi                                AS SalesDocType
FROM
    OQUT       AS q      -- Quote header
    INNER JOIN QUT1 AS l ON q.DocEntry = l.DocEntry  -- Quote lines
    LEFT  JOIN OSLP AS rep ON q.SlpCode   = rep.SlpCode
    LEFT  JOIN OCTG AS pt  ON q.GroupNum  = pt.GroupNum
    LEFT  JOIN OSHP AS shp ON q.TrnspCode = shp.TrnspCode
WHERE
    q.CANCELED = 'N'
    -- Optional filter (anonymized): pass a parameter instead of hard-coding a BP code
    -- AND q.CardCode = [%0]
ORDER BY
    q.DocNum ASC;
