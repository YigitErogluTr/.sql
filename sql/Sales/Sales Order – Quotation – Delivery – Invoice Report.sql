-- Sales Order – Quotation – Delivery – Invoice Report
-- ORDR/RDR1 (Sales Orders) + QUT1/OQUT (Quotations) + DLN1/ODLN (Deliveries) + INV1/OINV (Invoices) + OITM/OITB (Items) + OSLP (Salesperson)

SELECT 

    -- Quotation Information
    QH.DocNum                          AS "Quotation No",
    QH.CreateDate                       AS "Quotation System Date",
    QH.DocDate                          AS "Quotation Date",
    QH.DocDueDate                        AS "Quotation Valid Until",
    QL.ItemCode                          AS "Quotation Item Code",
    QL.Dscription                        AS "Quotation Item Description",
    QL.Quantity                          AS "Quotation Quantity",
    QL.Price                             AS "Quotation Unit Price",
    QL.Currency                          AS "Quotation Currency",
    QL.WhsCode                           AS "Quotation Warehouse",
    QH.Comments                          AS "Quotation Comments",
    CASE QH.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END AS "Quotation Status",
    CASE QH.CANCELED WHEN 'Y' THEN 'Canceled' ELSE '' END AS "Quotation Cancel Status",

    -- Sales Order Information
    SO.DocNum                            AS "Order No",
    SO.CreateDate                         AS "Order System Date",
    SO.DocDate                            AS "Order Date",
    SO.DocDueDate                         AS "Planned Delivery Date",
    SL.Quantity                           AS "Order Quantity",
    SL.Price                              AS "Order Unit Price",
    SL.Currency                           AS "Order Currency",
    SL.WhsCode                            AS "Order Warehouse",
    SO.Comments                           AS "Order Comments",
    CASE SO.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END AS "Order Status",
    CASE SO.CANCELED WHEN 'Y' THEN 'Canceled' ELSE '' END AS "Order Cancel Status",

    -- Delivery / Goods Issue
    DLH.DocNum                            AS "Delivery No",
    DLH.CreateDate                         AS "Delivery System Date",
    DLH.DocDate                            AS "Actual Delivery Date",
    DL.Quantity                            AS "Delivery Quantity",
    DL.Price                               AS "Delivery Unit Price",
    DL.Currency                            AS "Delivery Currency",
    DL.WhsCode                             AS "Delivery Warehouse",
    DLH.U_H1_eIrsaliyeNo                   AS "Delivery Note No",
    CASE DLH.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END AS "Delivery Status",
    CASE DLH.CANCELED WHEN 'Y' THEN 'Canceled' ELSE '' END AS "Delivery Cancel Status",

    -- Invoice
    IH.DocNum                             AS "Invoice No",
    IH.CreateDate                          AS "Invoice System Date",
    IH.DocDate                             AS "Invoice Date",
    IH.DocDueDate                          AS "Payment Due Date",
    IL.Quantity                            AS "Invoice Quantity",
    IL.Price                               AS "Invoice Unit Price",
    IL.Currency                            AS "Invoice Currency",
    IH.NumAtCard                           AS "NumAtCard",
    CASE IH.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END AS "Invoice Status",
    CASE IH.CANCELED WHEN 'Y' THEN 'Canceled' ELSE '' END AS "Invoice Cancel Status",

    -- Item Information
    IB.ItmsGrpNam                          AS "Item Group",
    I.U_stokkodgrup                         AS "Item Category",
    SL.ItemCode                             AS "Stock Code",
    SL.Dscription                            AS "Stock Description",
    SL.UomCode                               AS "Unit of Measure",

    -- Customer and Salesperson
    SO.CardCode                             AS "Customer Code",
    SO.CardName                             AS "Customer Name",
    SP.SlpName                               AS "Salesperson"

FROM ORDR SO
INNER JOIN RDR1 SL ON SO.DocEntry = SL.DocEntry

-- Quotation Link
LEFT JOIN QUT1 QL ON 
    SL.BaseType = 23 AND  -- 23 = Quotation
    SL.BaseEntry = QL.DocEntry AND
    SL.BaseLine = QL.LineNum

LEFT JOIN OQUT QH ON QL.DocEntry = QH.DocEntry

-- Delivery Link
LEFT JOIN DLN1 DL ON 
    DL.BaseType = 17 AND
    DL.BaseEntry = SL.DocEntry AND
    DL.BaseLine = SL.LineNum

LEFT JOIN ODLN DLH ON DL.DocEntry = DLH.DocEntry

-- Invoice Link
LEFT JOIN INV1 IL ON 
    IL.BaseType = 13 AND  -- 13 = Delivery
    IL.BaseEntry = DL.DocEntry AND
    IL.BaseLine = DL.LineNum

LEFT JOIN OINV IH ON IL.DocEntry = IH.DocEntry

-- Item Details
LEFT JOIN OITM I ON SL.ItemCode = I.ItemCode
LEFT JOIN OITB IB ON I.ItmsGrpCod = IB.ItmsGrpCod

-- Salesperson
LEFT JOIN OSLP SP ON SO.SlpCode = SP.SlpCode

ORDER BY SO.DocNum, DLH.DocNum, IH.DocNum, QH.DocNum;
