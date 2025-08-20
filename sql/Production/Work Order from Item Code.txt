/*
    Production Order with Components

    This query retrieves production orders (OWOR) and their related components (WOR1).
    It shows planned vs. completed quantities for the finished product,
    along with the component requirements and issued quantities.

    Parameters:
    [%2] = Filter for Item Code (supports partial search)
*/

SELECT
    H.[DocNum] AS [Production Order Number],
    H.[ItemCode] AS [Finished Item Code],
    H.[ProdName] AS [Finished Item Name],
    I.U_urungrup AS [Product Group], -- Custom UDF: Product Group
    H.[PlannedQty] AS [Planned Quantity],
    H.[CmpltQty] AS [Completed Quantity],
    C.[ItemCode] AS [Component Item Code],
    C.ItemName AS [Component Item Name],
    C.[BaseQty] AS [Base Quantity],
    C.[PlannedQty] AS [Planned Component Quantity],
    C.[IssuedQty] AS [Issued Quantity]
FROM OWOR H
INNER JOIN WOR1 C 
    ON H.[DocEntry] = C.[DocEntry]
LEFT JOIN OITM I 
    ON H.ItemCode = I.ItemCode
WHERE H.[ItemCode] LIKE '%[%2]%'
ORDER BY H.[DocNum];
