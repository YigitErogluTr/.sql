/* 📊 Production Order Link Report
   - Shows the relationship between source and target production orders
   - Includes order numbers, item codes, quantities, and key dates
*/

SELECT 
    A.DocEntry     AS SourceOrderID,          -- Source production order number
    C.DocEntry     AS TargetOrderID,          -- Target production order number
    A.ItemCode     AS ItemCode,               -- Produced item code in source order
    A.CmpltQty     AS SourceCompletedQty,     -- Completed quantity in source order
    A.PostDate     AS SourcePostDate,         -- Posting date of source order
    C.PostDate     AS TargetPostDate,         -- Posting date of target order
    A.StartDate    AS SourceStartDate,        -- Start date of source order
    C.StartDate    AS TargetStartDate         -- Start date of target order
FROM 
    OWOR A WITH (NOLOCK)                      -- Source production order
    INNER JOIN WOR5 B WITH (NOLOCK) 
        ON A.DocEntry = B.RefDocEntr          -- Link between source and target
    INNER JOIN OWOR C WITH (NOLOCK) 
        ON B.DocEntry = C.DocEntry;           -- Target production order
