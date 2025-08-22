/* Batch on-hand and valuation by item / warehouse / batch (positive balances only) */

SELECT
    tl.ItemCode                                      AS ItemCode,
    itm.ItemName                                     AS ItemDescription,
    tl.LocCode                                       AS WarehouseCode,
    btn.DistNumber                                   AS BatchNumber,
    SUM(tl1.Quantity)                                AS OnHandQty,
    CASE
        WHEN btn.Quantity > 0 THEN btn.CostTotal / btn.Quantity
        ELSE 0
    END                                              AS UnitCost,
    SUM(tl1.Quantity) *
        CASE
            WHEN btn.Quantity > 0 THEN btn.CostTotal / btn.Quantity
            ELSE 0
        END                                          AS InventoryValue,
    itb.ItmsGrpNam                                   AS ItemGroup,
    itm.InvntryUom                                   AS InventoryUoM,
    itm.ItmsGrpCod                                   AS ItemGroupCode
FROM OITL AS tl WITH (NOLOCK)
LEFT JOIN ITL1 AS tl1 WITH (NOLOCK)
    ON tl.LogEntry = tl1.LogEntry
   AND tl.ItemCode = tl1.ItemCode
LEFT JOIN OBTN AS btn WITH (NOLOCK)
    ON tl1.ItemCode  = btn.ItemCode
   AND tl1.SysNumber = btn.SysNumber
LEFT JOIN OITM AS itm WITH (NOLOCK)
    ON tl.ItemCode = itm.ItemCode
LEFT JOIN OITB AS itb WITH (NOLOCK)
    ON itm.ItmsGrpCod = itb.ItmsGrpCod
WHERE
    COALESCE(btn.DistNumber, '') <> ''
GROUP BY
    tl.ItemCode,
    tl.LocCode,
    btn.DistNumber,
    btn.CostTotal,
    btn.Quantity,
    itm.ItemName,
    itm.ItmsGrpCod,
    itb.ItmsGrpNam,
    itm.InvntryUom
HAVING
    SUM(tl1.Quantity) > 0
ORDER BY
    ItemCode,
    WarehouseCode,
    BatchNumber;
