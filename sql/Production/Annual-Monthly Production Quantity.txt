/* Production Orders Summary (Planned vs Completed) */

SELECT
    YEAR(W.PostDate)          AS Year,
    MONTH(W.PostDate)         AS Month,
    W.ItemCode                AS ItemCode,
    W.ProdName                AS ProductName,
    COUNT(W.DocNum)           AS TotalOrders,
    SUM(W.PlannedQty)         AS TotalPlannedQty,
    SUM(W.CmpltQty)           AS TotalCompletedQty,
    G.ItmsGrpNam              AS ItemGroup,        -- Item Group Name
    I.U_stokkodgrup           AS StockCodeGroup,   -- Custom Stock Code Group
    C.PrcName                 AS CostCenter,       -- Cost Center
    I.U_urungrup              AS ProductGroup      -- Custom Product Group
FROM OWOR AS W
LEFT JOIN OITM AS I ON W.ItemCode = I.ItemCode
LEFT JOIN OITB AS G ON I.ItmsGrpCod = G.ItmsGrpCod
LEFT JOIN OPRC AS C ON I.U_H1_UretimBolumu = C.PrcCode
WHERE
    W.PostDate BETWEEN [%0] AND [%1]
GROUP BY
    YEAR(W.PostDate),
    MONTH(W.PostDate),
    W.ItemCode,
    W.ProdName,
    G.ItmsGrpNam,
    I.U_stokkodgrup,
    C.PrcName,
    I.U_urungrup
ORDER BY
    Year DESC,
    Month DESC,
    W.ItemCode;
