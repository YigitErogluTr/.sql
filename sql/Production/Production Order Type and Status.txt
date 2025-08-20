/* 📋 Production Orders Overview
   - Retrieves production order headers from OWOR
   - Translates order type and status codes into readable values
   - Includes posting date, closing date, comments, and origin reference
*/

SELECT
    WO.DocNum                           AS DocumentNumber,
    CASE WO.Type
        WHEN 'S' THEN 'Standard'
        WHEN 'D' THEN 'Disassembly'
        WHEN 'P' THEN 'Special'
        ELSE WO.Type
    END                                 AS OrderType,
    CASE WO.Status
        WHEN 'L' THEN 'Closed'
        WHEN 'C' THEN 'Cancelled'
        WHEN 'R' THEN 'Approved'
        WHEN 'P' THEN 'Planned'
        ELSE WO.Status
    END                                 AS OrderStatus,
    WO.PostDate                         AS PostingDate,
    WO.CloseDate                        AS ClosingDate,
    WO.Comments                         AS Comments,
    WO.OriginNum                        AS OriginOrderNumber
FROM dbo.OWOR AS WO;
