/* Alternative Items without Standard BOM Reference */

SELECT
    A.Father        AS ParentItem,
    A.Code          AS ComponentCode,
    A.Quantity      AS ComponentQty,
    A.Uom           AS UnitOfMeasure
FROM ATT1 AS A
WHERE
    A.Father NOT IN (
        SELECT DISTINCT B.Father
        FROM ITT1 AS B
    )
    AND A.Father LIKE '%[%2]%';
