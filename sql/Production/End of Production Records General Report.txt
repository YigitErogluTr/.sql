/* 📦 Work Orders with Components & Resources (anonymized)
   - OWOR details + linked components (WOR1) + resource name (ORSC)
   
*/

WITH WorkOrders AS (
    SELECT
        W.DocNum                                        AS WorkOrderNo,
        CASE W.Type
            WHEN 'S' THEN 'Standard'
            WHEN 'D' THEN 'Disassembly'
            WHEN 'P' THEN 'Special'
            ELSE W.Type
        END                                             AS WorkOrderType,
        CASE W.Status
            WHEN 'L' THEN 'Closed'
            WHEN 'C' THEN 'Canceled'
            WHEN 'R' THEN 'Approved'
            WHEN 'P' THEN 'Planned'
            ELSE W.Status
        END                                             AS WorkOrderStatus,
        W.DueDate                                       AS DueDate,
        MONTH(W.DueDate)                                AS DueMonthNo,
        W.StartDate                                     AS StartDate,
        MONTH(W.StartDate)                              AS StartMonthNo,
        W.PostDate                                      AS PostDate,
        MONTH(W.PostDate)                               AS PostMonthNo,
        W.CloseDate                                     AS CloseDate,
        CASE
            WHEN W.CloseDate IS NOT NULL THEN MONTH(W.CloseDate)
            ELSE NULL
        END                                             AS CloseMonthNo,
        CASE W.LinkToObj
            WHEN 202 THEN 'Production Order'
            WHEN 17  THEN 'Sales Order'
            ELSE NULL
        END                                             AS LinkedDocType,
        W.OriginNum                                     AS LinkedDocNo,
        W.U_fasonuretim                                 AS IsSubcontracted,   -- custom field
        G.ItmsGrpNam                                    AS ItemGroupName,
        W.ItemCode                                      AS ProductCode,
        I.U_stokkodgrup                                 AS StockCodeGroup,
        W.CmpltQty                                      AS CompletedQty,
        W.Uom                                           AS UoM,
        W.Comments                                      AS Comments,
        I.U_H1_UretimBolumu                             AS CostCenterCode,     -- custom field
        C.PrcName                                       AS CostCenterName,
        I.U_urungrup                                    AS ProductGroup        -- custom field
    FROM dbo.OWOR AS W
    LEFT JOIN dbo.OITM AS I
        ON W.ItemCode = I.ItemCode
    LEFT JOIN dbo.OPRC AS C
        ON I.U_H1_UretimBolumu = C.PrcCode
    LEFT JOIN dbo.OITB AS G
        ON I.ItmsGrpCod = G.ItmsGrpCod
),
WorkOrderComponents AS (
    SELECT
        W.DocNum                                        AS WorkOrderNo,
        R.ItemCode                                      AS ComponentCode,
        RES.ResName                                     AS ResourceName
    FROM dbo.OWOR AS W
    LEFT JOIN dbo.WOR1 AS R
        ON W.DocEntry = R.DocEntry
    LEFT JOIN dbo.ORSC AS RES
        ON R.ItemCode = RES.VisResCode
)
SELECT
    A.WorkOrderNo,
    A.WorkOrderType,
    A.WorkOrderStatus,
    A.DueDate,
    A.DueMonthNo,
    A.StartDate,
    A.StartMonthNo,
    A.PostDate,
    A.PostMonthNo,
    A.CloseDate,
    A.CloseMonthNo,
    A.LinkedDocType,
    A.LinkedDocNo,
    A.IsSubcontracted,
    A.ItemGroupName,
    A.ProductCode,
    A.StockCodeGroup,
    A.CompletedQty,
    A.UoM,
    A.Comments,
    A.CostCenterCode,
    A.CostCenterName,
    A.ProductGroup,
    B.ComponentCode,
    B.ResourceName
FROM WorkOrders AS A
INNER JOIN WorkOrderComponents AS B
    ON A.WorkOrderNo = B.WorkOrderNo
ORDER BY
    A.WorkOrderNo ASC;
