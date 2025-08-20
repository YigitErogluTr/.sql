/* Bill of Materials (BOM) with Component Details */

SELECT
    H.Code        AS ParentItem,        -- BOM Header (Finished Product)
    H.Qauntity    AS ParentQuantity,    -- Header Quantity (note: check typo Qauntity → Quantity)
    C.Code        AS ComponentItem,     -- Component Item
    C.Quantity    AS ComponentQuantity  -- Component Quantity
FROM OITT AS H
INNER JOIN ITT1 AS C
    ON H.Code = C.Father
WHERE
    C.Type = '4'              -- Filter by component type (e.g., production item)
    AND H.Code LIKE '%[%2]%'; -- Runtime parameter filter
