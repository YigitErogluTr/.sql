/* Inventory Turnover from Invoices (per item) */

SELECT
    L.ItemCode                                AS ItemCode,
    L.Dscription                              AS ItemDescription,
    SUM(L.Quantity)                           AS InvoicedQty,
    COALESCE(AVG(I.OnHand), 0)                AS StockOnHand,             -- total on-hand (item level)
    COALESCE(SUM(L.Quantity) / NULLIF(AVG(I.OnHand), 0), 0) AS InventoryTurnover,
    DATEDIFF(DAY, MIN(H.DocDate), MAX(H.DocDate))          AS InvoiceSpanDays,
    COALESCE(
        (SUM(L.Quantity) / NULLIF(AVG(I.OnHand), 0))
        / NULLIF(DATEDIFF(DAY, MIN(H.DocDate), MAX(H.DocDate)), 0),
        0
    )                                          AS TurnoverPerDay,
    MIN(H.DocDate)                             AS FirstInvoiceDate,
    MAX(H.DocDate)                             AS LastInvoiceDate
FROM OINV AS H
INNER JOIN INV1 AS L
        ON H.DocEntry = L.DocEntry
LEFT JOIN OITM AS I
       ON L.ItemCode = I.ItemCode
WHERE H.CANCELED = 'N'
GROUP BY
    L.ItemCode,
    L.Dscription
ORDER BY
    TurnoverPerDay DESC;
