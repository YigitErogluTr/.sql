/* Inventory by batch (lot) vs. non-batch, with unit/total cost per warehouse */

WITH BatchTracking AS (
    SELECT
        'COMPANY'                                 AS Company,
        itl.ItemCode                              AS ItemCode,
        itm.ItemName                              AS ItemDescription,
        itl.LocCode                               AS WarehouseCode,
        btn.DistNumber                            AS BatchNumber,
        SUM(itl1.Quantity)                        AS OnHandQty,
        CASE
            WHEN ISNULL(btn.Quantity, 0) > 0 THEN btn.CostTotal / btn.Quantity
            ELSE 0
        END                                       AS UnitCost,
        SUM(itl1.Quantity) *
        CASE
            WHEN ISNULL(btn.Quantity, 0) > 0 THEN btn.CostTotal / btn.Quantity
            ELSE 0
        END                                       AS TotalCost,
        itb.ItmsGrpNam                            AS ItemGroup,
        itm.InvntryUom                            AS InventoryUoM
    FROM OITL AS itl WITH (NOLOCK)
    LEFT JOIN ITL1 AS itl1 WITH (NOLOCK)
        ON itl.LogEntry = itl1.LogEntry AND itl.ItemCode = itl1.ItemCode
    LEFT JOIN OBTN AS btn WITH (NOLOCK)
        ON itl1.ItemCode = btn.ItemCode AND itl1.SysNumber = btn.SysNumber
    LEFT JOIN OITM AS itm ON itl.ItemCode = itm.ItemCode
    LEFT JOIN OITB AS itb ON itm.ItmsGrpCod = itb.ItmsGrpCod
    WHERE
        COALESCE(btn.DistNumber, '') <> ''
        AND itm.ItmsGrpCod NOT IN (108, 109, 113, 114, 116)   -- excluded groups
    GROUP BY
        itl.ItemCode, itl.LocCode, btn.DistNumber, btn.CostTotal, btn.Quantity,
        itm.ItemName, itm.ItmsGrpCod, itb.ItmsGrpNam, itm.InvntryUom
    HAVING
        SUM(itl1.Quantity) > 0
),
NonBatchTracking AS (
    SELECT
        'COMPANY'                                 AS Company,
        itm.ItemCode                              AS ItemCode,
        itm.ItemName                              AS ItemDescription,
        itw.WhsCode                               AS WarehouseCode,
        'NO BATCH TRACKING'                       AS BatchNumber,
        itw.OnHand                                AS OnHandQty,
        itm.AvgPrice                              AS UnitCost,
        itw.OnHand * itm.AvgPrice                 AS TotalCost,
        itb.ItmsGrpNam                            AS ItemGroup,
        itm.InvntryUom                            AS InventoryUoM
    FROM OITM AS itm
    INNER JOIN OITW AS itw ON itm.ItemCode = itw.ItemCode
    INNER JOIN OITB AS itb ON itm.ItmsGrpCod = itb.ItmsGrpCod
    WHERE
        itm.ManBtchNum = 'N'
        AND itw.OnHand > 0
        AND itm.ItmsGrpCod NOT IN (108, 109, 113, 114, 116)   -- excluded groups
)

SELECT
    Company,
    ItemCode,
    ItemDescription,
    WarehouseCode,
    BatchNumber,
    OnHandQty,
    UnitCost,
    TotalCost,
    ItemGroup,
    InventoryUoM
FROM BatchTracking

UNION ALL

SELECT
    Company,
    ItemCode,
    ItemDescription,
    WarehouseCode,
    BatchNumber,
    OnHandQty,
    UnitCost,
    TotalCost,
    ItemGroup,
    InventoryUoM
FROM NonBatchTracking

ORDER BY
    ItemCode, WarehouseCode, BatchNumber;
