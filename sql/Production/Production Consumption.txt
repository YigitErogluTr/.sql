/* 📦 Goods Issue linked to Production Orders (BaseType = 202) */

SELECT
    GI.DocDate               AS PostingDate,
    GI.DocNum                AS GoodsIssueNo,
    GI1.BaseRef              AS ProductionOrderNo,
    GI1.ItemCode             AS ItemCode,
    GI1.Dscription           AS ItemDescription,
    GI1.Quantity             AS IssuedQty,
    GI1.WhsCode              AS WarehouseCode,
    GI1.PriceBefDi           AS UnitPriceBeforeDiscount,
    GI1.unitMsr              AS UoM
FROM dbo.OIGE AS GI
INNER JOIN dbo.IGE1 AS GI1
    ON GI.DocEntry = GI1.DocEntry
WHERE
    GI1.BaseType = 202               -- 202 = Production Order
    AND GI.DocDate BETWEEN [%0] AND [%1]
ORDER BY
    GI.DocDate ASC;
