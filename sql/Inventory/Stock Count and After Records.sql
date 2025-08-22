/* Combined Inventory Transactions: Stock Count, Goods Receipt, Goods Issue */

SELECT
    q.DocEntry                  AS DocumentNumber,
    'Stock Count'               AS SourceTable,
    q.DocDate                   AS DocumentDate,
    ql.ItemCode                 AS ItemCode,
    i.ItemName                  AS ItemName,
    i.InvntryUom                AS InventoryUoM,
    ql.Quantity                 AS Quantity,
    ql.Price                    AS UnitPrice,
    ql.Quantity * ql.Price      AS LineTotal,
    NULL                        AS BaseReference
FROM dbo.OIQR AS q
INNER JOIN dbo.IQR1 AS ql
    ON q.DocEntry = ql.DocEntry
INNER JOIN dbo.OITM AS i
    ON ql.ItemCode = i.ItemCode

UNION ALL

SELECT
    gr.DocEntry                 AS DocumentNumber,
    'Goods Receipt'             AS SourceTable,
    gr.DocDate                  AS DocumentDate,
    grl.ItemCode                AS ItemCode,
    i.ItemName                  AS ItemName,
    i.InvntryUom                AS InventoryUoM,
    grl.Quantity                AS Quantity,
    grl.Price                   AS UnitPrice,
    grl.Quantity * grl.Price    AS LineTotal,
    NULL                        AS BaseReference
FROM dbo.OIGN AS gr
INNER JOIN dbo.IGN1 AS grl
    ON gr.DocEntry = grl.DocEntry
INNER JOIN dbo.OITM AS i
    ON grl.ItemCode = i.ItemCode
WHERE
    (grl.BaseRef IS NULL OR gr.DocEntry = 68868)

UNION ALL

SELECT
    gi.DocEntry                     AS DocumentNumber,
    'Goods Issue'                   AS SourceTable,
    gi.DocDate                      AS DocumentDate,
    gil.ItemCode                    AS ItemCode,
    i.ItemName                      AS ItemName,
    i.InvntryUom                     AS InventoryUoM,
    gil.Quantity * -1               AS Quantity,
    gil.Price                       AS UnitPrice,
    (gil.Quantity * -1) * gil.Price AS LineTotal,
    gil.BaseRef                     AS BaseReference
FROM dbo.OIGE AS gi
INNER JOIN dbo.IGE1 AS gil
    ON gi.DocEntry = gil.DocEntry
INNER JOIN dbo.OITM AS i
    ON gil.ItemCode = i.ItemCode
WHERE
    gil.BaseRef IS NULL

ORDER BY
    DocumentDate,
    DocumentNumber;
