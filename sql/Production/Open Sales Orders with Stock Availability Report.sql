-- Open Sales Orders with Stock Availability Report
-- ORDR/RDR1 (Sales Orders) + OITM (Items)

SELECT 
    SO.DocNum                         AS "Sales Order No", 
    SO.DocDate                         AS "Order Date", 
    SO.DocDueDate                       AS "Delivery Date", 
    SO.CardCode                         AS "Customer Code", 
    SO.CardName                         AS "Customer Name", 
    SL.ItemCode                         AS "Stock Code", 
    SL.Dscription                        AS "Stock Description", 
    SL.OpenCreQty                        AS "Open Quantity",  
    I.OnHand                             AS "Available Stock",
    SL.OpenCreQty - I.OnHand             AS "Quantity To Produce"
FROM ORDR SO
INNER JOIN RDR1 SL ON SO.DocEntry = SL.DocEntry
INNER JOIN OITM I ON SL.ItemCode = I.ItemCode
WHERE I.ItmsGrpCod = 100
  AND SO.DocStatus = 'O'
  AND SL.OpenCreQty - I.OnHand > 0
ORDER BY SO.DocNum, SL.ItemCode;
