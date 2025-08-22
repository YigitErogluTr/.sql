/* 📋 Production Orders with Row Count Validation
   - Lists production orders (OWOR) and their row count from WOR1
   - Excludes items containing 'PRS' or 'IST'
   - Only includes orders without subcontract production flag (U_fasonuretim)
   - Filters to orders where row count is not equal to 10
*/

SELECT
    WO.DocNum           AS DocumentNumber,
    COUNT(*)            AS RowCount
FROM dbo.WOR1 AS W1
INNER JOIN dbo.OWOR AS WO
    ON WO.DocEntry = W1.DocEntry
WHERE
    W1.ItemType = 290
    AND W1.ItemCode NOT LIKE '%PRS%'
    AND W1.ItemCode NOT LIKE '%IST%'
    AND (WO.U_fasonuretim IS NULL OR WO.U_fasonuretim = '')
GROUP BY
    WO.DocNum
HAVING
    COUNT(*) <> 10;
