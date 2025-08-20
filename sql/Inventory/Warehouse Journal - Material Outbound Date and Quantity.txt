/* Outgoing Stock Transactions (OINM) */

SELECT
    N.ItemCode        AS ItemCode,
    I.ItemName        AS ItemName,
    N.DocDate         AS ExitDate,
    N.BaseRef         AS BaseRef,
    N.CardName        AS BusinessPartner,
    N.Warehouse       AS Warehouse,
    N.OutQty          AS OutQuantity
FROM OINM AS N
JOIN OITM AS I
     ON N.ItemCode = I.ItemCode
WHERE N.OutQty > 0
ORDER BY N.DocDate DESC;
