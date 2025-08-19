SELECT
    Q.DocEntry          AS [Document Number],
    Q.DocDate           AS [Document Date],
    QL.ItemCode         AS [Item Code],
    QL.Dscription       AS [Item Description],

    -- Last Purchase Price
    (
        SELECT TOP 1 P.Price
        FROM POR1 P
        WHERE P.ItemCode = QL.ItemCode
        ORDER BY P.DocDate DESC
    ) AS [Last Purchase Price],

    -- Last Purchase Date
    (
        SELECT TOP 1 P.DocDate
        FROM POR1 P
        WHERE P.ItemCode = QL.ItemCode
        ORDER BY P.DocDate DESC
    ) AS [Last Purchase Date],

    QL.Quantity         AS [Quantity],
    QL.Price            AS [Unit Price],
    QL.Currency         AS [Currency],
    QL.Rate             AS [Exchange Rate],
    QL.LineTotal        AS [Line Total (LC)],
    QL.TotalFrgn        AS [Line Total (FC)],

    Pmt.PymntGroup      AS [Payment Terms],
    Q.ReqDate           AS [Requested Date],
    Q.CardCode          AS [Vendor Code],
    Q.CardName          AS [Vendor Name],
    QL.Text             AS [Item Details],
    Q.Comments          AS [Comments]

FROM OPQT Q
INNER JOIN PQT1 QL 
    ON Q.DocEntry = QL.DocEntry
INNER JOIN OCTG Pmt
    ON Q.GroupNum = Pmt.GroupNum

WHERE Q.DocStatus = 'O'
ORDER BY 
    QL.ItemCode,
    QL.Price;
