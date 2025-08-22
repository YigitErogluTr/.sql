/*
  Sales Quotation Lines
  ---------------------
  - Retrieves items from sales quotations
  - Filters out zero quantity lines
  - Parameterized by DocNum
*/

SELECT  
    H.[DocDate]       AS [DocumentDate],
    H.[CreateDate]    AS [CreatedOn],
    L.[ItemCode]      AS [ItemCode],
    L.[ItemName]      AS [ItemName],
    L.[Price]         AS [UnitPrice],
    L.[Quantity]      AS [Quantity],
    L.[Currency]      AS [Currency]
FROM 
    dbo.OIQI H
INNER JOIN 
    dbo.IQI1 L ON H.[DocEntry] = L.[DocEntry]
WHERE 
    H.[DocNum] = /* [%0] */ 1      -- replace with parameter
    AND L.[Quantity] <> 0;
