/* Open purchase orders with line details */

SELECT
    po.DocNum                               AS DocumentNumber,
    po.DocStatus                            AS DocumentStatus,
    po.DocDueDate                           AS PlannedReceiptDate,
    pol.ItemCode                            AS ItemCode,
    pol.Dscription                          AS ItemDescription,
    pol.Quantity                            AS Quantity,
    pol.Price                               AS UnitPrice,
    pol.Currency                            AS PriceCurrency,
    pol.LineTotal                           AS LineTotalLC,      -- local currency total
    pol.Rate                                AS ExchangeRate,
    pol.WhsCode                             AS WarehouseCode,
    pol.UomCode                             AS UoM
FROM dbo.POR1 AS pol
INNER JOIN dbo.OPOR AS po
    ON po.DocEntry = pol.DocEntry
WHERE po.DocStatus = 'O';
