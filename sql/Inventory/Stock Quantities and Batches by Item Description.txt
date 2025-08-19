/* Batch Stock by Item Search */

SELECT
    i.ItemCode            AS ItemCode,
    i.ItemName            AS ItemName,
    b.BatchNum            AS BatchNumber,
    b.WhsCode             AS WarehouseCode,
    b.Quantity            AS Quantity,
    i.InvntryUom          AS InventoryUoM,
    g.ItmsGrpNam          AS ItemGroup
FROM dbo.OIBT AS b
INNER JOIN dbo.OITM AS i ON b.ItemCode = i.ItemCode
INNER JOIN dbo.OITB AS g ON i.ItmsGrpCod = g.ItmsGrpCod
WHERE i.ItemName LIKE '%[%2]%'
  AND b.Quantity <> 0;
