-- Supplier Delivery Performance Report
-- Shows average delivery time, total delivered quantity, and total purchase orders per supplier

SELECT  
    PO.CardCode       AS [Supplier Code],  
    PO.CardName       AS [Supplier Name],  
    AVG(DATEDIFF(DAY, PO.DocDueDate, POL.DocDate)) AS [Avg Delivery Time (Days)],  
    SUM(POL.Quantity) AS [Total Delivered Quantity],  
    COUNT(POL.DocEntry) AS [Total Orders]  
FROM  
    OPOR PO
    INNER JOIN POR1 POL ON PO.DocEntry = POL.DocEntry  
WHERE  
    PO.CANCELED = 'N'  
GROUP BY  
    PO.CardCode,  
    PO.CardName  
ORDER BY  
    [Avg Delivery Time (Days)] ASC;
