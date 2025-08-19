/* Batch inventory valuation by item, group, batch, and warehouse (date range filtered) */

SELECT
    mt.ItemCode                                   AS ItemCode,
    itb.ItmsGrpNam                                AS ItemGroup,
    bt.DistNumber                                 AS BatchNumber,
    SUM(mtl.Quantity)                             AS BatchBalanceQty,
    SUM(mtl.Quantity) *
        CASE WHEN bt.Quantity <> 0
             THEN bt.CostTotal / bt.Quantity
             ELSE 0
        END                                        AS BatchInventoryValue,
    bt.InDate                                      AS BatchProductionDate,
    CASE WHEN bt.Quantity <> 0
         THEN bt.CostTotal / bt.Quantity
         ELSE 0
    END                                            AS UnitCost,
    bt.CostTotal                                   AS BatchTotalCost,
    bt.Quantity                                    AS BatchTotalReceiptQty,
    itm.ItemName                                   AS ItemDescription,
    mt.LocCode                                     AS WarehouseCode
FROM OITL AS mt WITH (NOLOCK)
LEFT JOIN ITL1 AS mtl WITH (NOLOCK)
    ON mt.LogEntry = mtl.LogEntry
   AND mt.ItemCode = mtl.ItemCode
LEFT JOIN OBTN AS bt WITH (NOLOCK)
    ON mtl.ItemCode  = bt.ItemCode
   AND mtl.SysNumber = bt.SysNumber
LEFT JOIN OITM AS itm WITH (NOLOCK)
    ON mt.ItemCode = itm.ItemCode
LEFT JOIN OITB AS itb WITH (NOLOCK)
    ON itm.ItmsGrpCod = itb.ItmsGrpCod
WHERE
    mt.DocDate BETWEEN [%0] AND [%1]
    AND ISNULL(bt.DistNumber, '') <> ''
GROUP BY
    bt.InDate,
    bt.DistNumber,
    bt.CostTotal,
    bt.Quantity,
    mt.ItemCode,
    itm.ItemName,
    itb.ItmsGrpNam,
    mt.LocCode
ORDER BY
    ItemGroup,
    ItemCode;
