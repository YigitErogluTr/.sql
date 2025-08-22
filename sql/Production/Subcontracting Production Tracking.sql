/*
    Production Material Movements Report

    This query combines:
    - Goods Receipts from Production (IGN1 / OIGN)
    - Goods Issues to Production (IGE1 / OIGE)
    - Stock Transfers between warehouses (WTR1 / OWTR)

    It shows item-level movements for selected item groups (e.g., Finished Goods, Semi-Finished Goods)
    filtered by warehouse prefix (e.g., 'FSN%') and a given date range.

    Parameters:
    [%0] = Start Date
    [%1] = End Date
*/

WITH ProductionReceipt AS (
    SELECT
        R1.ItemCode,
        MAX(I.ItemName) AS ItemName,
        MAX(G.ItmsGrpNam) AS ItemGroup,
        R1.WhsCode,
        SUM(R1.Quantity) AS ReceiptQty
    FROM IGN1 R1
    INNER JOIN OITM I ON I.ItemCode = R1.ItemCode
    INNER JOIN OITB G ON G.ItmsGrpCod = I.ItmsGrpCod
    INNER JOIN OIGN H ON H.DocEntry = R1.DocEntry
    WHERE 
        G.ItmsGrpNam IN ('FINISHED_GOODS', 'SEMI_FINISHED')
        AND R1.WhsCode LIKE 'FSN%'
        AND H.DocDate BETWEEN [%0] AND [%1]
    GROUP BY R1.ItemCode, R1.WhsCode
),
ProductionIssue AS (
    SELECT
        I1.ItemCode,
        MAX(I.ItemName) AS ItemName,
        MAX(G.ItmsGrpNam) AS ItemGroup,
        I1.WhsCode,
        SUM(I1.Quantity) AS IssueQty
    FROM IGE1 I1
    INNER JOIN OITM I ON I.ItemCode = I1.ItemCode
    INNER JOIN OITB G ON G.ItmsGrpCod = I.ItmsGrpCod
    INNER JOIN OIGE H ON H.DocEntry = I1.DocEntry
    WHERE
        G.ItmsGrpNam IN ('FINISHED_GOODS', 'SEMI_FINISHED')
        AND I1.WhsCode LIKE 'FSN%'
        AND H.DocDate BETWEEN [%0] AND [%1]
    GROUP BY I1.ItemCode, I1.WhsCode
),
StockTransfer AS (
    SELECT
        ItemCode,
        MAX(ItemName) AS ItemName,
        MAX(ItemGroup) AS ItemGroup,
        WarehouseCode,
        SUM(Qty) AS TransferQty
    FROM (
        -- Incoming transfer to warehouse
        SELECT
            T1.ItemCode,
            I.ItemName,
            G.ItmsGrpNam AS ItemGroup,
            T1.WhsCode AS WarehouseCode,
            T1.Quantity AS Qty
        FROM WTR1 T1
        INNER JOIN OITM I ON I.ItemCode = T1.ItemCode
        INNER JOIN OITB G ON G.ItmsGrpCod = I.ItmsGrpCod
        INNER JOIN OWTR H ON H.DocEntry = T1.DocEntry
        WHERE 
            G.ItmsGrpNam IN ('FINISHED_GOODS', 'SEMI_FINISHED')
            AND T1.WhsCode LIKE 'FSN%'
            AND H.DocDate BETWEEN [%0] AND [%1]

        UNION ALL

        -- Outgoing transfer from warehouse (negative quantity)
        SELECT
            T1.ItemCode,
            I.ItemName,
            G.ItmsGrpNam AS ItemGroup,
            T1.FromWhsCod AS WarehouseCode,
            -T1.Quantity AS Qty
        FROM WTR1 T1
        INNER JOIN OITM I ON I.ItemCode = T1.ItemCode
        INNER JOIN OITB G ON G.ItmsGrpCod = I.ItmsGrpCod
        INNER JOIN OWTR H ON H.DocEntry = T1.DocEntry
        WHERE 
            G.ItmsGrpNam IN ('FINISHED_GOODS', 'SEMI_FINISHED')
            AND T1.FromWhsCod LIKE 'FSN%'
            AND H.DocDate BETWEEN [%0] AND [%1]
    ) AS TransferMovements
    GROUP BY ItemCode, WarehouseCode
)

SELECT
    COALESCE(r.ItemCode, i.ItemCode, t.ItemCode) AS [Item Code],
    COALESCE(r.ItemName, i.ItemName, t.ItemName) AS [Item Name],
    COALESCE(r.ItemGroup, i.ItemGroup, t.ItemGroup) AS [Item Group],
    COALESCE(r.WhsCode, i.WhsCode, t.WarehouseCode) AS [Warehouse],
    ISNULL(r.ReceiptQty, 0) AS [Production Receipt],
    ISNULL(i.IssueQty, 0) AS [Production Issue],
    ISNULL(t.TransferQty, 0) AS [Stock Transfer]
FROM ProductionReceipt r
FULL OUTER JOIN ProductionIssue i
    ON r.ItemCode = i.ItemCode AND r.WhsCode = i.WhsCode
FULL OUTER JOIN StockTransfer t
    ON COALESCE(r.ItemCode, i.ItemCode) = t.ItemCode
   AND COALESCE(r.WhsCode, i.WhsCode) = t.WarehouseCode
ORDER BY [Item Code];
