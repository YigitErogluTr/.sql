/* Incoming Stock Transactions (OINM) */

SELECT
    N.ItemCode            AS ItemCode,
    I.ItemName            AS ItemName,
    N.DocDate             AS EntryDate,
    N.BaseRef             AS BaseRef,
    N.CardName            AS BusinessPartner,
    N.Warehouse           AS Warehouse,
    N.InQty               AS InQuantity
FROM OINM AS N
JOIN OITM AS I
     ON N.ItemCode = I.ItemCode
WHERE N.InQty > 0
ORDER BY N.DocDate DESC;
