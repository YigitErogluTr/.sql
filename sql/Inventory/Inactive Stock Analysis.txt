/* Items with positive on-hand and their last inventory movement date */

SELECT
    ig.ItmsGrpNam                           AS ItemGroupName,
    i.ItemCode                              AS ItemCode,
    i.ItemName                              AS ItemName,
    w.OnHand                                AS OnHandQuantity,
    (
        SELECT MAX(m.DocDate)
        FROM dbo.OINM AS m
        WHERE m.ItemCode = i.ItemCode
    )                                       AS LastMovementDate
FROM dbo.OITM AS i
INNER JOIN dbo.OITW AS w
    ON i.ItemCode = w.ItemCode
INNER JOIN dbo.OITB AS ig
    ON i.ItmsGrpCod = ig.ItmsGrpCod
WHERE w.OnHand > 0
ORDER BY LastMovementDate ASC;
