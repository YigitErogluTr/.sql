/* 📋 Goods Receipt Notes – Date Consistency Check
   - Retrieves GRN (OIGN) documents from 2024
   - Compares document date (DocDate) vs creation date (CreateDate)
   - Flags mismatches as "Date Mismatch"
*/

SELECT
    YEAR(GRN.DocDate)              AS Year,
    GRN.DocNum                     AS DocumentNumber,
    GRN.DocDate                    AS DocumentDate,
    GRN.CreateDate                 AS CreationDate,
    CASE
        WHEN GRN.DocDate <> GRN.CreateDate
            THEN 'Date Mismatch'
        ELSE ''
    END                            AS Status
FROM dbo.OIGN AS GRN
WHERE YEAR(GRN.DocDate) = 2024;
