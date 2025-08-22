/* 📊 Production Orders without subcontracting flag (U_fasonuretim)
   - Only Cancelled (C) or Closed (L) orders
   - U_fasonuretim is NULL or empty
*/

SELECT 
    DocNum,
    ItemCode,
    Warehouse,
    PostDate,
    StartDate,
    DueDate,
    OriginNum,
    Comments,

    -- 🔹 Order Type
    CASE 
        WHEN Type = 'S' THEN 'Standart'
        WHEN Type = 'D' THEN 'Demontaj'
        WHEN Type = 'P' THEN N'Özel'
        ELSE 'Diğer'
    END AS Tür,

    -- 🔹 Status
    CASE 
        WHEN Status = 'C' THEN 'İptal Edildi'
        WHEN Status = 'L' THEN 'Kapalı'
        WHEN Status = 'P' THEN 'Planlandı'
        WHEN Status = 'R' THEN 'Onaylandı'
        ELSE 'Diğer'
    END AS Durum,

    U_fasonuretim

FROM OWOR
WHERE 
    Status IN ('C', 'L')
    AND (U_fasonuretim IS NULL OR U_fasonuretim = '')
ORDER BY 
    DocNum DESC;
