/* Stock Transfers with Optional Link to Transfer Requests */

SELECT
    T0.DocNum                         AS TransferDocNo,
    T0.DocDate                        AS DocumentDate,
    T0.Filler                         AS SourceWarehouse,
    T0.ToWhsCode                      AS TargetWarehouse,
    T1.ItemCode                       AS ItemCode,
    T1.Dscription                     AS ItemDescription,
    T1.Quantity                       AS Quantity,
    T1.UnitMsr                        AS UoM,
    T4.OpenQty                        AS RequestOpenQty,
    U.U_NAME                          AS CreatedByUser,
    S.SlpName                         AS BuyerName,
    CASE
        WHEN T1.BaseEntry IS NULL THEN 'No Transfer Request'
        ELSE CAST(T1.BaseEntry AS varchar(50))
    END                                AS TransferRequestRef,
    T4.DocEntry                       AS TransferRequestDocEntry
FROM OWTR AS T0
INNER JOIN WTR1 AS T1
        ON T0.DocEntry = T1.DocEntry
INNER JOIN OUSR AS U
        ON T0.UserSign = U.USERID
INNER JOIN OSLP AS S
        ON T0.SlpCode = S.SlpCode
LEFT JOIN WTQ1 AS T4
       ON T1.BaseEntry = T4.DocEntry
WHERE T0.Filler IN ('WAREHOUSE_A', 'WAREHOUSE_B')   -- anonymized warehouses
  AND T0.Canceled <> 'Y'
ORDER BY T0.DocDate DESC, T0.DocNum, T1.LineNum;
