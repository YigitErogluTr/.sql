/* Batch Stock Balances (OIBT) */

SELECT
    I.ItemCode        AS ItemCode,
    I.ItemName        AS ItemName,
    B.BatchNum        AS BatchNumber,
    B.WhsCode         AS Warehouse,
    B.Quantity        AS Quantity,
    I.InvntryUom      AS UoM,
    G.ItmsGrpNam      AS ItemGroup
FROM OIBT AS B
INNER JOIN OITM AS I
        ON B.ItemCode = I.ItemCode
INNER JOIN OITB AS G
        ON I.ItmsGrpCod = G.ItmsGrpCod
WHERE B.Quantity <> 0;
