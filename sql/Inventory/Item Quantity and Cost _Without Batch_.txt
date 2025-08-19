/* Non-batch-tracked items with positive on-hand balance (inventory valuation by warehouse) */

SELECT
    i.ItemCode                 AS ItemCode,
    i.ItemName                 AS ItemName,
    w.WhsCode                  AS WarehouseCode,
    'BATCH TRACKING NOT APPLICABLE' AS BatchTrackingStatus,
    w.OnHand                   AS OnHandQuantity,
    i.AvgPrice                 AS AverageCost,
    (w.OnHand * i.AvgPrice)    AS TotalInventoryValue,
    g.ItmsGrpNam               AS ItemGroupName,
    i.InvntryUom               AS InventoryUoM,
    i.ItmsGrpCod               AS ItemGroupCode
FROM dbo.OITM AS i
INNER JOIN dbo.OITW AS w
    ON i.ItemCode = w.ItemCode
INNER JOIN dbo.OITB AS g
    ON i.ItmsGrpCod = g.ItmsGrpCod
WHERE
    i.ManBtchNum = 'N'     -- not batch-managed
    AND w.OnHand > 0
ORDER BY
    i.ItemCode;
