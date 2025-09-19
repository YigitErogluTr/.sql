-- Open Quotations Report
-- OQUT (Quotation Header) + QUT1 (Quotation Lines) + OSLP (Salesperson) + OCTG (Payment Terms) + OSHP (Shipping)

SELECT 
    H.DocNum                         AS "Quotation No",
    H.DocStatus                       AS "Status",
    H.Printed                         AS "Printed",
    CONVERT(VARCHAR, H.DocDate, 23)   AS "Document Date",
    CONVERT(VARCHAR, H.DocDueDate, 23) AS "Quotation Valid Until",
    H.CardCode                         AS "Customer Code",
    H.CardName                         AS "Customer Name",
    H.U_AIF_ET_BuyerName                AS "Contact Person",
    H.U_AIF_ET_BillPhone                AS "Contact Phone",
    L.ItemCode                          AS "Item Code",
    L.Dscription                        AS "Item Description",
    L.Quantity                           AS "Quantity",
    L.Price                              AS "Unit Price",
    L.Rate                               AS "VAT Rate",
    L.LineTotal                          AS "Item Total",
    P.PymntGroup                         AS "Payment Terms",
    H.Comments                           AS "Comments",
    H.U_AIF_ET_OrderNo                    AS "Order No",
    H.NumAtCard                          AS "Customer Ref No",
    S.TrnspName                          AS "Shipping Company",
    SP.SlpName                            AS "Salesperson",
    H.U_H1_BelgeTipi                       AS "Document Type"
FROM OQUT H  
INNER JOIN QUT1 L ON H.DocEntry = L.DocEntry
LEFT JOIN OSLP SP ON H.SlpCode = SP.SlpCode
LEFT JOIN OCTG P ON H.GroupNum = P.GroupNum
LEFT JOIN OSHP S ON H.TrnspCode = S.TrnspCode 
WHERE H.CANCELED = 'N'
ORDER BY H.DocNum ASC, L.LineNum ASC;
