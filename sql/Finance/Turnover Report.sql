/*
  Invoice Line Turnover (Header + Line + BP + Salesperson + Item Group)
  - Excludes canceled invoices
  - Computes local-currency unit price and line amount (VAT excluded)
  - Anonymizes custom UDF columns with neutral aliases
*/

SELECT
    H.[DocDate]      AS [RecordDate],
    H.[DocDueDate]   AS [DueDate],
    H.[TaxDate]      AS [DocumentDate],
    MONTH(H.[TaxDate]) AS [DocumentMonth],
    YEAR(H.[TaxDate])  AS [DocumentYear],
    H.[DocEntry]     AS [DocumentEntry],
    H.[CANCELED]     AS [IsCanceled],

    H.[CardCode]     AS [BPCode],
    H.[CardName]     AS [BPName],
    BP.[GroupCode]   AS [BPGroupCode],
    BPG.[GroupName]  AS [BPGroupName],

    CASE WHEN ISNULL(H.[ShipToCode], '') <> '' THEN H.[ShipToCode]
         ELSE 'SHIP TO BILLING ADDRESS'
    END              AS [ShipToCode],
    H.[Address2]     AS [ShipToAddress],

    -- Custom UDFs anonymized with neutral aliases
    H.[U_AIF_ET_OrderNo]   AS [UDF_OrderNo],
    H.[U_H1_eIrsaliyeNo]   AS [UDF_eDispatchNo],
    H.[U_H1_BelgeTipi]     AS [UDF_SalesDocType],

    H.[SlpCode]      AS [SalesEmployeeCode],
    SLP.[SlpName]    AS [SalesEmployeeName],

    L.[WhsCode]      AS [WarehouseCode],

    ITM.[ItmsGrpCod] AS [ItemGroupCode],
    ITB.[ItmsGrpNam] AS [ItemGroupName],
    ITM.[U_stokkodgrup] AS [UDF_ItemCodeGroup],

    L.[ItemCode]     AS [ItemCode],
    L.[Dscription]   AS [ItemDescription],
    L.[Quantity]     AS [Quantity],
    L.[UomCode]      AS [UoMCode],
    L.[PriceBefDi]   AS [UnitPrice],          -- header currency
    H.[DocCur]       AS [DocumentCurrency],
    L.[Rate]         AS [CurrencyRate],

    -- Local currency unit price (TRY-Equivalent Unit Price)
    CASE
        WHEN L.[Rate] IS NULL OR L.[Rate] = 0 THEN L.[PriceBefDi]
        ELSE L.[PriceBefDi] * L.[Rate]
    END              AS [LocalUnitPrice],

    -- Local currency line amount (VAT excluded)
    L.[Quantity] *
    CASE
        WHEN L.[Rate] IS NULL OR L.[Rate] = 0 THEN L.[PriceBefDi]
        ELSE L.[PriceBefDi] * L.[Rate]
    END              AS [LocalLineAmountExclVAT],

    L.[VatGroup]     AS [VATGroup],
    CASE L.[VatGroup]
        WHEN 's05' THEN '%0'
        ELSE ''

    END              AS [VATRateText]
FROM dbo.INV1 AS L
INNER JOIN dbo.OINV AS H  ON H.[DocEntry]  = L.[DocEntry]
INNER JOIN dbo.OCRD AS BP  ON H.[CardCode] = BP.[CardCode]
INNER JOIN dbo.OCRG AS BPG ON BP.[GroupCode] = BPG.[GroupCode]
INNER JOIN dbo.OSLP AS SLP ON H.[SlpCode] = SLP.[SlpCode]
INNER JOIN dbo.OITM AS ITM ON L.[ItemCode] = ITM.[ItemCode]
INNER JOIN dbo.OITB AS ITB ON ITM.[ItmsGrpCod] = ITB.[ItmsGrpCod]
WHERE H.[CANCELED] = 'N';
