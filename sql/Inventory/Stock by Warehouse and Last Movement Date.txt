/* Current Stock by Item & Warehouse + Last Movement Date */

SELECT
    G.ItmsGrpNam                                      AS ItemGroup,
    I.ItemCode                                        AS ItemCode,
    I.ItemName                                        AS ItemName,
    W.WhsCode                                         AS WarehouseCode,
    W.OnHand                                          AS OnHandQty,
    (
        SELECT MAX(M.DocDate)
        FROM OINM AS M
        WHERE M.ItemCode = I.ItemCode
          AND M.Warehouse = W.WhsCode
    )                                                 AS LastMovementDate
FROM OITM AS I
INNER JOIN OITW AS W
        ON I.ItemCode = W.ItemCode
INNER JOIN OITB AS G
        ON I.ItmsGrpCod = G.ItmsGrpCod
WHERE W.OnHand > 0
ORDER BY LastMovementDate ASC;
