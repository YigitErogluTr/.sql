/*
  Resource Consumption vs Standard vs Actual (by Work Order)
  - Anonymized & parameterized
  - Pulls resource issues from Material Issue (IGE1/OIGE) for production orders (BaseType = 202)
  - Compares standard amounts (line totals) vs actual amounts from resource master UDF

  Parameters:
    @StartDate : DATE (inclusive)
    @EndDate   : DATE (inclusive)
*/

DECLARE @StartDate DATE = '2025-03-01';
DECLARE @EndDate   DATE = '2025-03-31';

SELECT
    A.ItemCode                                             AS ResourceCode,
    B.ResName                                              AS ResourceName,
    C.ResGrpNam                                            AS ResourceGroupName,
    COALESCE(B.U_H1_UretimBolumu, '')                      AS ProductionDepartment,   -- UDF (anonymized alias)
    A.BaseEntry                                            AS WorkOrderNo,
    A.Quantity                                             AS ConsumedResourceQty,
    A.LineTotal                                            AS StdPeriodResourceAmount,
    A.LineTotal / NULLIF(A.Quantity, 0)                    AS StdPeriodUnitCost,
    COALESCE(B.U_SNT_Fiili_KaynakBirimMaliyeti, 0) * A.Quantity AS ActualResourceAmount,  -- UDF
    COALESCE(B.U_SNT_Fiili_KaynakBirimMaliyeti, 0)         AS ActualUnitCost,            -- UDF
    COALESCE(B.U_SNT_Fiili_KaynakBirimMaliyeti, 0) * A.Quantity - A.LineTotal
                                                           AS StdVsActualVarianceAmount
FROM dbo.IGE1 AS A WITH (NOLOCK)
LEFT JOIN dbo.ORSC AS B WITH (NOLOCK)
    ON A.ItemCode = B.ResCode
LEFT JOIN dbo.ORSB AS C WITH (NOLOCK)
    ON B.ResGrpCod = C.ResGrpCod
WHERE
    A.BaseType = 202            -- production order
    AND A.ItemType = 290        -- resource issue lines
    AND A.DocDate >= @StartDate
    AND A.DocDate < DATEADD(DAY, 1, @EndDate)
ORDER BY
    C.ResGrpNam,
    A.ItemCode;
