/* 📊 Production In/Out Report
   - Combines Production Receipts (OIGN) and Production Issues (OIGE)
   - Both linked to Production Orders (BaseType = 202)
   - Date range filter applied between [%0] and [%1]
   - Source column [Kaynak] indicates whether the row is a Receipt (ÜRETİM) or Consumption (TÜKETİM)
*/

SELECT
    'PRODUCTION RECEIPT'       AS Source,       -- ÜRETİM
    R.DocDate                  AS DocumentDate,
    RL.BaseRef                 AS ProductionOrderNumber,
    RL.ItemCode                AS ItemCode,
    RL.Dscription              AS ItemDescription,
    RL.Quantity                AS Quantity,
    RL.WhsCode                 AS WarehouseCode,
    RL.PriceBefDi              AS PriceBeforeDiscount,
    RL.unitMsr                 AS UnitOfMeasure
FROM dbo.OIGN AS R
INNER JOIN dbo.IGN1 AS RL
    ON R.DocEntry = RL.DocEntry
WHERE
    RL.BaseType = 202
    AND R.DocDate BETWEEN [%0] AND [%1]

UNION ALL

SELECT
    'PRODUCTION ISSUE'         AS Source,       -- TÜKETİM
    I.DocDate                  AS DocumentDate,
    IL.BaseRef                 AS ProductionOrderNumber,
    IL.ItemCode                AS ItemCode,
    IL.Dscription              AS ItemDescription,
    IL.Quantity                AS Quantity,
    IL.WhsCode                 AS WarehouseCode,
    IL.PriceBefDi              AS PriceBeforeDiscount,
    IL.unitMsr                 AS UnitOfMeasure
FROM dbo.OIGE AS I
INNER JOIN dbo.IGE1 AS IL
    ON I.DocEntry = IL.DocEntry
WHERE
    IL.BaseType = 202
    AND I.DocDate BETWEEN [%0] AND [%1]

ORDER BY
    DocumentDate,
    ProductionOrderNumber;
