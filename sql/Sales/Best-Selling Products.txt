-- Sales Report by Item
-- Summarizes sales quantity and total amount by product within a date range

SELECT  
    L.ItemCode       AS [Item Code],  
    I.ItemName       AS [Item Name],  
    SUM(L.Quantity)  AS [Sales Quantity],  
    SUM(L.LineTotal) AS [Total Sales Amount (LC)]  

FROM  
    OINV H                -- Invoice Header  
    INNER JOIN INV1 L ON H.DocEntry = L.DocEntry   -- Invoice Lines  
    INNER JOIN OITM I ON L.ItemCode = I.ItemCode   -- Item Master  

WHERE  
    H.DocDate BETWEEN [%0] AND [%1]  

GROUP BY  
    L.ItemCode,  
    I.ItemName  

ORDER BY  
    [Sales Quantity] DESC;
