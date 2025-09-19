-- Sales Order Change Log Report
-- Shows all changes and the current status for sales orders
-- ADOC (Audit) + ORDR (Header) + RDR1 (Lines) + OUSR (Users)

WITH Changes AS (
    SELECT 
        A.DocNum                         AS "Sales Order No",
        A.LogInstanc                      AS "Log Instance",
        A.UpdateDate                      AS "Change_UpdateDate",
        A.UpdateTS                        AS "Change_UpdateTS",
        A.CardCode                        AS "Customer Code",
        A.CardName                        AS "Customer Name",
        A.DocDate                         AS "Document Date",
        A.DocDueDate                      AS "Delivery Date",
        A.NumAtCard                        AS "Customer Ref",
        A.Address                         AS "Billing Address",
        A.ShipToCode                       AS "Shipping Address",
        A.PayToCode                        AS "Payment Address",
        A.DocTotal                        AS "Total Amount",
        A.VatSum                           AS "Tax",
        A.Comments                        AS "Comments",
        A.DocCur                           AS "Currency",
        L.ItemCode                         AS "Item Code",
        L.Dscription                       AS "Item Description",
        L.Quantity                          AS "Quantity",
        L.Price                             AS "Unit Price",
        U1.USER_CODE                        AS "Updated By",
        U2.USER_CODE                        AS "Approved By",
        -- Previous values per document
        LAG(A.CardCode) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Customer Code",
        LAG(A.CardName) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Customer Name",
        LAG(A.DocDueDate) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Delivery Date",
        LAG(A.Address) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Billing Address",
        LAG(A.ShipToCode) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Shipping Address",
        LAG(A.PayToCode) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Payment Address",
        LAG(A.DocTotal) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Total Amount",
        LAG(A.VatSum) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Tax",
        LAG(L.ItemCode) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Item Code",
        LAG(L.Dscription) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Item Description",
        LAG(L.Quantity) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Quantity",
        LAG(L.Price) OVER (PARTITION BY A.DocNum ORDER BY A.UpdateDate, A.UpdateTS) AS "Prev Unit Price",
        'Change'                            AS "Type"
    FROM ADOC A
    LEFT JOIN ORDR H ON A.DocNum = H.DocNum
    LEFT JOIN RDR1 L ON H.DocEntry = L.DocEntry
    LEFT JOIN OUSR U1 ON A.UserSign = U1.USERID
    LEFT JOIN OUSR U2 ON A.UserSign2 = U2.USERID
    WHERE A.ObjType = 17
),
CurrentStatus AS (
    SELECT
        H.DocNum                         AS "Sales Order No",
        NULL                               AS "Log Instance",
        H.UpdateDate                       AS "Change_UpdateDate",
        H.UpdateTS                         AS "Change_UpdateTS",
        H.CardCode                         AS "Customer Code",
        H.CardName                         AS "Customer Name",
        H.DocDate                          AS "Document Date",
        H.DocDueDate                        AS "Delivery Date",
        H.NumAtCard                         AS "Customer Ref",
        H.Address                          AS "Billing Address",
        H.ShipToCode                         AS "Shipping Address",
        H.PayToCode                          AS "Payment Address",
        H.DocTotal                          AS "Total Amount",
        H.VatSum                             AS "Tax",
        H.Comments                          AS "Comments",
        H.DocCur                             AS "Currency",
        L.ItemCode                           AS "Item Code",
        L.Dscription                         AS "Item Description",
        L.Quantity                            AS "Quantity",
        L.Price                               AS "Unit Price",
        U1.USER_CODE                          AS "Updated By",
        U2.USER_CODE                          AS "Approved By",
        H.CardCode                             AS "Prev Customer Code",
        H.CardName                             AS "Prev Customer Name",
        H.DocDueDate                            AS "Prev Delivery Date",
        H.Address                              AS "Prev Billing Address",
        H.ShipToCode                             AS "Prev Shipping Address",
        H.PayToCode                              AS "Prev Payment Address",
        H.DocTotal                               AS "Prev Total Amount",
        H.VatSum                                  AS "Prev Tax",
        L.ItemCode                                AS "Prev Item Code",
        L.Dscription                              AS "Prev Item Description",
        L.Quantity                                 AS "Prev Quantity",
        L.Price                                    AS "Prev Unit Price",
        'Current Status'                          AS "Type"
    FROM ORDR H
    LEFT JOIN RDR1 L ON H.DocEntry = L.DocEntry
    LEFT JOIN OUSR U1 ON H.UserSign = U1.USERID
    LEFT JOIN OUSR U2 ON H.UserSign2 = U2.USERID
)
SELECT *
FROM Changes
UNION ALL
SELECT *
FROM CurrentStatus
ORDER BY "Sales Order No", "Change_UpdateDate" ASC, "Change_UpdateTS" ASC, "Item Code", "Type" DESC;
