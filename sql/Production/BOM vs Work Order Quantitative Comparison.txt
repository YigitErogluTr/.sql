/* 📊 Work Order vs BOM Consumption Variance Report
   - Compares planned vs. actual material usage
   - Highlights discrepancies between BOM and production issue
*/

SELECT
    W.DocNum AS WorkOrderNo,                   -- Work Order Number
    W.ItemCode AS FinishedItemCode,            -- Finished Good Code
    W.PlannedQty AS PlannedProductionQty,      -- Planned Production Quantity

    ISNULL(WR.ItemCode, B.Code) AS ComponentCode,      -- Material Code (from Issue or BOM)
    ISNULL(M.ItemName, BM.ItemName) AS ComponentName,  -- Material Name
    ISNULL(G1.ItmsGrpNam, G2.ItmsGrpNam) AS ItemGroup, -- Material Group

    -- BOM Theoretical Consumption (BOM Qty * Planned Production Qty)
    ISNULL(B.Quantity,0) * ISNULL(W.PlannedQty,0) AS TheoreticalConsumption,

    -- Work Order Planned Consumption
    ISNULL(WR.PlannedQty,0) AS PlannedConsumption,

    -- Work Order Actual Consumption
    ISNULL(WR.IssuedQty,0) AS ActualConsumption,

    -- Variance (Actual - Theoretical)
    (ISNULL(WR.IssuedQty,0) - (ISNULL(B.Quantity,0) * ISNULL(W.PlannedQty,0))) AS Variance,

    -- % Realization (Actual vs Theoretical)
    CASE
        WHEN ISNULL(B.Quantity,0) * ISNULL(W.PlannedQty,0) = 0
            THEN NULL
        ELSE ROUND(ISNULL(WR.IssuedQty,0) / (B.Quantity * W.PlannedQty) * 100, 2)
    END AS PercentRealization,

    -- Status Flag
    CASE
        WHEN WR.ItemCode IS NULL AND B.Code IS NOT NULL THEN 'Only in BOM'
        WHEN WR.ItemCode IS NOT NULL AND B.Code IS NULL THEN 'Only in Work Order'
        ELSE 'Present in Both'
    END AS StatusFlag

FROM OWOR W                                -- Work Order Header
LEFT JOIN WOR1 WR ON W.DocEntry = WR.DocEntry      -- Work Order Components
FULL OUTER JOIN ITT1 B
    ON W.ItemCode = B.Father
    AND WR.ItemCode = B.Code                -- BOM Components

-- Join for material names
LEFT JOIN OITM M  ON WR.ItemCode = M.ItemCode
LEFT JOIN OITM BM ON B.Code     = BM.ItemCode

-- Join for material groups
LEFT JOIN OITB G1 ON M.ItmsGrpCod  = G1.ItmsGrpCod
LEFT JOIN OITB G2 ON BM.ItmsGrpCod = G2.ItmsGrpCod

WHERE
    ISNULL(W.Status,'') <> 'C'   -- Exclude Closed Work Orders
    AND ISNULL(G1.ItmsGrpCod, G2.ItmsGrpCod) IN (100,101,102,103,104,105,106,107,111)

ORDER BY
    W.DocNum,
    ComponentCode;
