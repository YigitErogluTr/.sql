/* Batch Transactions Report with Document Type & Movement Direction */

SELECT
    b.DocDate                      AS DocumentDate,
    b.ItemCode                      AS ItemCode,
    b.ItemName                      AS ItemName,
    b.BatchNum                      AS BatchNumber,
    b.WhsCode                       AS Warehouse,
    b.BaseType                      AS BaseType,
    b.BaseEntry                     AS BaseEntry,
    CASE b.BaseType
        WHEN '67'        THEN 'Stock Transfer'
        WHEN '10000071'  THEN 'Stock Count Entry'
        WHEN '59'        THEN 'Goods Receipt'
        WHEN '15'        THEN 'Delivery'
        WHEN '60'        THEN 'Goods Issue'
        WHEN '21'        THEN 'Return'
        WHEN '20'        THEN 'Purchase Order Receipt'
        WHEN '1250000001' THEN 'Transfer Request'
        WHEN '16'        THEN 'Customer Return'
        WHEN '19'        THEN 'Vendor Invoice'
        ELSE 'Other'
    END                            AS DocumentType,
    b.Quantity                      AS Quantity,
    b.CardCode                      AS BusinessPartnerCode,
    b.CardName                      AS BusinessPartnerName,
    CASE 
        WHEN b.Direction = 1     THEN 'Issue'
        WHEN b.Direction IS NULL THEN 'Receipt'
        ELSE 'Receipt'
    END                            AS MovementDirection
FROM dbo.IBT1 AS b
WHERE b.DocDate BETWEEN [%0] AND [%1]
ORDER BY b.BatchNum, b.DocDate ASC;
