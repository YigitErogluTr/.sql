/* 📊 Released Production Orders (OWOR)
   - Lists released (Status = 'L') production orders
   - Shows subcontracting (fason) info
   - Links to newly created follow-up production orders (if any)
*/

SELECT
    -- 🔹 Order Type
    CASE 
        WHEN T1.Type = 'S' THEN 'Standart'
        WHEN T1.Type = 'D' THEN 'Demontaj'
        WHEN T1.Type = 'P' THEN N'Özel'
        ELSE T1.Type
    END AS OrderType,

    -- 🔹 Production Order Info
    T1.DocEntry,
    T1.PostDate,
    T1.StartDate,
    T1.CloseDate,

    -- 🔹 Item Info
    T1.ItemCode,
    T1.ProdName,
    T1.U_fasonuretim AS [Fason Üretim],   -- custom field (subcontract prod. flag)

    -- 🔹 Comments with linked new production order
    'Yeni Ürt.Sip.No ' +
        (SELECT TOP 1 CAST(X.DocNum AS NVARCHAR(20))
         FROM OWOR X WITH (NOLOCK)
         WHERE X.OriginNum = T1.DocNum) +
    ' Yeni Ürt.Sip.Açıklama ' +
        ISNULL(
            (SELECT TOP 1 X.Comments
             FROM OWOR X WITH (NOLOCK)
             WHERE X.OriginNum = T1.DocNum),''
        ) AS Comments,

    -- 🔹 Business Partner & Warehouse
    T1.CardCode,
    T1.Warehouse,

    -- 🔹 Quantities
    T1.PlannedQty,
    T1.CmpltQty,
    T1.RjctQty,
    (T1.PlannedQty - T1.CmpltQty + T1.RjctQty) AS OpenQty, -- remaining qty

    -- 🔹 References
    T1.OriginNum,
    T1.Project,
    T1.LinkToObj

FROM OWOR T1 WITH (NOLOCK)
INNER JOIN OITM T2 WITH (NOLOCK) 
    ON T1.ItemCode = T2.ItemCode
WHERE
    T1.Status = 'L'       -- only Released orders
    -- AND T1.Type != 'D'  -- uncomment if you want to exclude Demontaj
ORDER BY
    T1.DocEntry DESC;
