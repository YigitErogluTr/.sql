-- Open Sales Orders with Delivery Status Report
-- ORDR (Header) + RDR1 (Lines) + ODLN/DLN1 (Delivery)

SELECT
    H."DocNum"           AS "Sales Order No",
    H."DocDate"          AS "Order Date",

    L."LineStatus"       AS "Line Status",
    L."ItemCode"         AS "Item Code",
    L."Dscription"       AS "Item Description",
    L."Quantity"         AS "Ordered Quantity",
    L."DelivrdQty"       AS "Delivered Quantity",
    L."OpenQty"          AS "Remaining Quantity",
    L."ShipDate"         AS "Planned Delivery Date",

    DATEDIFF(DAY, L."ShipDate", GETDATE()) AS "Delay (Days)",

    CASE
        WHEN L."OpenQty" > 0 AND GETDATE() > L."ShipDate"
            THEN 'Delayed'
        ELSE 'On Time'
    END AS "Delivery Status",

    D."DocNum"           AS "Delivery Document No",
    D."DocDate"          AS "Delivery Date"

FROM
    "ORDR" H              -- Sales Order Header
    INNER JOIN "RDR1" L   -- Sales Order Lines
        ON H."DocEntry" = L."DocEntry"
    LEFT JOIN "DLN1" DL   -- Delivery Note Lines
        ON L."DocEntry" = DL."BaseEntry"
       AND L."LineNum"  = DL."BaseLine"
    LEFT JOIN "ODLN" D    -- Delivery Note Header
        ON DL."DocEntry" = D."DocEntry"

WHERE
    H."DocStatus" = 'O'   -- Only Open Orders

ORDER BY
    H."DocNum" DESC,
    L."LineNum" ASC;
