/*
    Production Orders vs BOM Consistency Check

    This query compares the Bill of Materials (BOM) with Production Orders (OWOR).
    It highlights:
    - Components that exist in BOM but are missing from the Production Order
    - Components that exist in the Production Order but are missing from the BOM

    Useful for identifying mismatches between BOM structure and actual production orders.

    Notes:
    - OITB item group codes are filtered to specific groups (example: 100–111).
    - UDF `U_H1_UretimBolumu` is assumed to represent the production department.
*/

-- Components in BOM but missing from Production Order
SELECT
    W.DocNum AS [Production Order No],
    W.PostDate AS [Posting Date],
    YEAR(W.PostDate) AS [Year],
    W.ItemCode AS [Parent Item Code],
    I1.ItemName AS [Parent Item Name],
    W.Uom AS [UoM],
    B.CompCode AS [BOM Component Code],
    I2.ItemName AS [BOM Component Name],
    D.OcrName AS [Production Department]
FROM OWOR W
INNER JOIN OITM I1 ON W.ItemCode = I1.ItemCode
INNER JOIN OITB G1 ON I1.ItmsGrpCod = G1.ItmsGrpCod
    AND G1.ItmsGrpCod IN (100,101,102,103,104,105,106,107,111)
LEFT JOIN OOCR D ON I1.U_H1_UretimBolumu = D.OcrCode
INNER JOIN (
    SELECT
        C.Father AS FatherCode,
        C.Code AS CompCode
    FROM ITT1 C
    INNER JOIN OITT H ON H.Code = C.Father
) B ON B.FatherCode = W.ItemCode
INNER JOIN OITM I2 ON B.CompCode = I2.ItemCode
INNER JOIN OITB G2 ON I2.ItmsGrpCod = G2.ItmsGrpCod
    AND G2.ItmsGrpCod IN (100,101,102,103,104,105,106,107,111)
LEFT JOIN WOR1 WO ON WO.DocEntry = W.DocEntry AND WO.ItemCode = B.CompCode
WHERE WO.ItemCode IS NULL

UNION ALL

-- Components in Production Order but missing from BOM
SELECT
    W.DocNum AS [Production Order No],
    W.PostDate AS [Posting Date],
    YEAR(W.PostDate) AS [Year],
    W.ItemCode AS [Parent Item Code],
    I1.ItemName AS [Parent Item Name],
    W.Uom AS [UoM],
    WO.ItemCode AS [Production Order Component Code],
    I2.ItemName AS [Production Order Component Name],
    D.OcrName AS [Production Department]
FROM OWOR W
INNER JOIN OITM I1 ON W.ItemCode = I1.ItemCode
INNER JOIN OITB G1 ON I1.ItmsGrpCod = G1.ItmsGrpCod
    AND G1.ItmsGrpCod IN (100,101,102,103,104,105,106,107,111)
LEFT JOIN OOCR D ON I1.U_H1_UretimBolumu = D.OcrCode
INNER JOIN WOR1 WO ON WO.DocEntry = W.DocEntry
INNER JOIN OITM I2 ON WO.ItemCode = I2.ItemCode
INNER JOIN OITB G2 ON I2.ItmsGrpCod = G2.ItmsGrpCod
    AND G2.ItmsGrpCod IN (100,101,102,103,104,105,106,107,111)
LEFT JOIN ITT1 C ON C.Father = W.ItemCode AND C.Code = WO.ItemCode
WHERE C.Code IS NULL

ORDER BY [Production Order No], [Parent Item Code], [BOM Component Code];
