-- Return Requests with Reasons & Referenced Documents (ORRR/RRR1)
-- Tables: RRR1 (Return Request - Rows) + ORRR (Return Request - Header) + ORER (Return Reasons master) + RRR21 (Referenced Docs)
-- Notes:
--  - All captions are English and generic.
--  - UDFs kept with generic captions.
--  - "Return Reason" shows 'No Reason Entered' when ReturnRsn = -1.
--  - Aggregates referenced document numbers via STRING_AGG.
--  - Excludes canceled documents.

SELECT
    -- Business Partner & Document
    T1.[CardCode]        AS [BP Code],
    T1.[CardName]        AS [BP Name],
    T0.[DocEntry]        AS [Document No],
    T1.[DocStatus]       AS [Document Status],
    T1.[DocDate]         AS [Posting Date],
    T1.[DocDueDate]      AS [Due Date],
    T1.[TaxDate]         AS [Document Date],

    -- Custom references (kept; generic captions)
    T1.[U_AIF_ET_OrderNo] AS [External Order No],
    T1.[NumAtCard]         AS [BP Reference No],
    T1.[U_H1_BelgeTipi]    AS [Sales Doc Type],

    -- Item & shipping
    T0.[ItemCode]        AS [Item Code],
    T0.[Dscription]      AS [Item Description],
    T0.[Quantity]        AS [Quantity],
    T0.[PriceBefDi]      AS [Unit Price (DocCur, excl. tax)],
    T0.[TaxCode]         AS [Tax Code],
    T0.[WhsCode]         AS [Warehouse],
    T0.[ShipToCode]      AS [Ship-To Code],
    T0.[ShipToDesc]      AS [Ship-To Description],

    -- Return reason (fallback when not provided)
    CASE 
        WHEN T0.[ReturnRsn] = -1 THEN N'No Reason Entered'
        ELSE T2.[Reason]
    END                  AS [Return Reason],

    -- Referenced documents (numbers only)
    STRING_AGG(T3.[RefDocNum], ', ') AS [Referenced Documents]

FROM [dbo].[RRR1]  AS T0
INNER JOIN [dbo].[ORRR]  AS T1 ON T1.[DocEntry] = T0.[DocEntry]
LEFT  JOIN [dbo].[ORER]  AS T2 ON T0.[ReturnRsn] = T2.[AbsEntry]
LEFT  JOIN [dbo].[RRR21] AS T3 ON T1.[DocNum]   = T3.[DocEntry]

WHERE T1.[CANCELED] = 'N'

GROUP BY 
    T1.[CardCode],
    T1.[CardName],
    T0.[DocEntry],
    T1.[DocStatus],
    T1.[DocDate],
    T1.[DocDueDate],
    T1.[TaxDate],
    T1.[U_AIF_ET_OrderNo],
    T1.[NumAtCard],
    T1.[U_H1_BelgeTipi],
    T0.[ItemCode],
    T0.[Dscription],
    T0.[Quantity],
    T0.[PriceBefDi],
    T0.[TaxCode],
    T0.[WhsCode],
    T0.[ShipToCode],
    T0.[ShipToDesc],
    T0.[ReturnRsn],
    T2.[Reason];
