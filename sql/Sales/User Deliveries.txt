-- Delivery Notes with user, warehouse, and line info (header + lines)
SELECT
    h.DocEntry                               AS DocumentNo,
    h.CreateDate                             AS CreatedAt,
    YEAR(h.CreateDate)                       AS Year,
    MONTH(h.CreateDate)                      AS Month,
    h.UpdateDate                             AS UpdatedAt,
    l.WhsCode                                AS WarehouseCode,
    u.U_NAME                                 AS CreatedByUser,     -- SAP B1 user display name
    l.ItemCode                               AS ItemCode,
    l.Dscription                             AS ItemDescription,
    h.CANCELED                               AS IsCanceled
FROM
    ODLN  AS h   -- Delivery header
    INNER JOIN DLN1 AS l  ON h.DocEntry = l.DocEntry  -- Delivery lines
    INNER JOIN OUSR AS u  ON h.UserSign = u.USERID    -- Creator user
-- Optional safety filters (uncomment if needed)
-- WHERE h.CANCELED = 'N'
ORDER BY
    h.CreateDate DESC;
