/* Stock Transactions Report — Last 24 Hours */

SELECT
    'COMPANY_NAME'            AS Company,
    T0.DocDate                AS DocumentDate,
    T0.TransType              AS DocumentTypeCode,
    CASE T0.TransType
        WHEN 20 THEN 'Purchase Goods Receipt'
        WHEN 59 THEN 'Goods Receipt'
        WHEN 60 THEN 'Goods Issue'
        WHEN 67 THEN 'Stock Transfer'
        WHEN 15 THEN 'Delivery'
        WHEN 21 THEN 'Goods Return'
        WHEN 69 THEN 'Goods Receipt'
        ELSE 'Other / Undefined'
    END                       AS DocumentTypeName,
    T0.BaseRef                AS DocumentNumber,
    T0.ItemCode               AS ItemCode,
    T0.Dscription             AS ItemDescription,
    T1.InvntryUom             AS UnitOfMeasure,
    T0.InQty                  AS InQuantity,
    T0.OutQty                 AS OutQuantity,
    T0.Warehouse              AS Warehouse,
    U.USER_CODE               AS UserName,
    T0.Comments               AS Comments,
    T0.JrnlMemo               AS JournalMemo
FROM OINM AS T0
LEFT JOIN OITM AS T1 
       ON T0.ItemCode = T1.ItemCode
LEFT JOIN OUSR AS U 
       ON T0.UserSign = U.USERID
WHERE T0.Warehouse IN ('WAREHOUSE_A', 'WAREHOUSE_B')
  AND T0.DocDate >= CAST(DATEADD(DAY, -1, CAST(GETDATE() AS DATE)) AS DATETIME)
  AND T0.DocDate <  CAST(CAST(GETDATE() AS DATE) AS DATETIME)
ORDER BY T0.DocDate, T0.BaseRef;
