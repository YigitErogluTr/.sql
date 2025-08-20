/* 📋 Production Receipt Linked to Production Orders
   - Retrieves Goods Receipt (OIGN) documents with lines from Production Orders
   - Filters by BaseType = 202 (Production Order)
   - Date range filter applied between [%0] and [%1]
*/

SELECT
    GRN.DocDate               AS DocumentDate,
    GRN.DocNum                AS DocumentNumber,
    L.BaseRef                 AS ProductionOrderNumber,
    L.ItemCode                AS ItemCode,
    L.Dscription              AS ItemDescription,
    L.Quantity                AS Quantity,
    L.WhsCode                 AS WarehouseCode,
    L.PriceBefDi              AS PriceBeforeDiscount,
    L.unitMsr                 AS UnitOfMeasure
FROM dbo.OIGN AS GRN
INNER JOIN dbo.IGN1 AS L 
    ON GRN.DocEntry = L.DocEntry
WHERE 
    L.BaseType = 202  -- Linked to Production Orders
    AND GRN.DocDate BETWEEN [%0] AND [%1]
ORDER BY 
    GRN.DocDate;
