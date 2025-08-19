/* Inventory by batch vs. non-batch items (warehouse-level) */

SELECT
    itm.ItemCode                    AS ItemCode,
    itm.ItemName                    AS ItemDescription,
    oibt.BatchNum                   AS BatchNumber,
    oibt.WhsCode                    AS WarehouseCode,
    oibt.Quantity                   AS OnHandQty,
    itb.ItmsGrpNam                  AS ItemGroup,
    itm.InvntryUom                  AS InventoryUoM
FROM OIBT AS oibt
INNER JOIN OITM AS itm
    ON oibt.ItemCode = itm.ItemCode
INNER JOIN OITB AS itb
    ON itm.ItmsGrpCod = itb.ItmsGrpCod
WHERE
    oibt.Quantity <> 0

UNION ALL

SELECT
    itm.ItemCode                    AS ItemCode,
    itm.ItemName                    AS ItemDescription,
    'NO BATCH TRACKING'             AS BatchNumber,
    itw.WhsCode                     AS WarehouseCode,
    itw.OnHand                      AS OnHandQty,
    itb.ItmsGrpNam                  AS ItemGroup,
    itm.InvntryUom                  AS InventoryUoM
FROM OITM AS itm
INNER JOIN OITW AS itw
    ON itm.ItemCode = itw.ItemCode
INNER JOIN OITB AS itb
    ON itm.ItmsGrpCod = itb.ItmsGrpCod
WHERE
    itm.ManBtchNum = 'N'
    AND itw.OnHand > 0

ORDER BY
    ItemCode, WarehouseCode, BatchNumber;
