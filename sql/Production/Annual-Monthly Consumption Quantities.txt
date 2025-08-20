/* Monthly Production Report by Item (Planned vs Issued) */

SELECT
    YEAR(W.StartDate)        AS Year,
    MONTH(W.StartDate)       AS Month,
    W.ItemCode               AS ItemCode,
    W.ItemName               AS ItemDescription,
    COUNT(W.DocEntry)        AS TotalDocs,
    SUM(W.PlannedQty)        AS TotalPlannedQty,    -- Sum of PlannedQty
    SUM(W.IssuedQty)         AS TotalIssuedQty,     -- Sum of IssuedQty
    W.UomCode                AS UoM,
    G.ItmsGrpNam             AS ItemGroup,          -- Item Group
    I.U_stokkodgrup          AS ItemCodeGroup,      -- Custom Stock Code Group
    C.PrcName                AS CostCenter,         -- Cost Center Name
    I.U_urungrup             AS ProductGroup        -- Custom Product Group
FROM WOR1 AS W
LEFT JOIN OITM AS I ON W.ItemCode = I.ItemCode
LEFT JOIN OITB AS G ON I.ItmsGrpCod = G.ItmsGrpCod
LEFT JOIN OPRC AS C ON I.U_H1_UretimBolumu = C.PrcCode
WHERE
    W.ItemType = 4
    AND W.StartDate BETWEEN [%0] AND [%1]
GROUP BY
    YEAR(W.StartDate),
    MONTH(W.StartDate),
    W.ItemCode,
    W.ItemName,
    W.UomCode,
    W.ItemType,
    G.ItmsGrpNam,
    I.U_stokkodgrup,
    C.PrcName,
    I.U_urungrup
ORDER BY
    YEAR(W.StartDate),
    MONTH(W.StartDate),
    W.ItemCode;
