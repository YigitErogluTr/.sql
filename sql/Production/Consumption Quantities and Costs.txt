/* 🔧 Consumption by Work Order (Issue from Inventory)
   - Period filter: [%0] .. [%1] on T0.DocDate
   - Shows item/group, warehouse, qty, cost, user, and cost center per work order
*/

SELECT
    T0.DocDate                                 AS DocDate,
    YEAR(T0.DocDate)                           AS DocYear,
    MONTH(T0.DocDate)                          AS DocMonthNo,
    DATENAME(MONTH, T0.DocDate)                AS DocMonthName,
    T0.DocEntry                                AS IssueDocEntry,
    T0.BaseRef                                 AS WorkOrderNo,
    T2.ItmsGrpNam                              AS ItemGroupName,
    T0.ItemCode                                AS ItemCode,
    T0.Dscription                              AS ItemDescription,
    T0.WhsCode                                 AS WarehouseCode,
    T0.Quantity                                AS ConsumptionQty,
    T0.UomCode                                 AS UoMCode,
    T0.StockPrice                              AS ItemUnitCost,
    T0.Quantity * T0.StockPrice                AS TotalCost,
    OWOR.U_FasonUretim                         AS IsSubcontractedProduction,
    OUSR.USER_CODE                             AS CreatedByCode,
    OUSR.U_NAME                                AS CreatedByName,
    T1.U_urungrup                              AS ProductGroup,
    T1.U_H1_UretimBolumu                       AS CostCenterCode,
    OPRC.PrcName                               AS CostCenterName
FROM dbo.IGE1 AS T0
INNER JOIN dbo.OITM AS T1
    ON T0.ItemCode = T1.ItemCode
INNER JOIN dbo.OITB AS T2
    ON T1.ItmsGrpCod = T2.ItmsGrpCod
INNER JOIN dbo.OWOR AS OWOR
    ON T0.BaseRef = OWOR.DocNum
INNER JOIN dbo.OUSR AS OUSR
    ON OWOR.UserSign = OUSR.USERID
LEFT JOIN dbo.OPRC AS OPRC
    ON T1.U_H1_UretimBolumu = OPRC.PrcCode
WHERE
    T0.ItemType = '4'               -- only material issues
    AND T0.BaseRef IS NOT NULL
    AND T0.BaseRef <> ''
    AND T1.ItmsGrpCod NOT IN (111, 113)
    AND T0.DocDate BETWEEN [%0] AND [%1]
ORDER BY
    T0.BaseRef ASC;
