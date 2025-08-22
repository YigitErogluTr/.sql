/* Items without Batch Tracking - Current Stock Report */

SELECT
    I.ItemCode       AS ItemCode,
    I.ItemName       AS ItemDescription,
    W.WhsCode        AS Warehouse,
    'NO BATCH TRACKING' AS BatchTrackingStatus,
    W.OnHand         AS StockQty,
    G.ItmsGrpNam     AS ItemGroup,
    I.InvntryUom     AS TrackingUoM,
    I.ItmsGrpCod     AS ItemGroupCode
FROM OITM AS I
INNER JOIN OITW AS W
        ON I.ItemCode = W.ItemCode
INNER JOIN OITB AS G
        ON I.ItmsGrpCod = G.ItmsGrpCod
WHERE I.ManBtchNum = 'N'
  AND W.OnHand > 0
ORDER BY I.ItemCode;
