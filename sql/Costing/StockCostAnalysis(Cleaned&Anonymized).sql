/*
  Stock Cost Analysis (Cleaned & Anonymized)
  - Parameterized & anonymized for GitHub sharing
  - Computes stock costs per item, including:
      * Stock quantity per warehouse
      * Weighted unit cost per stock item (corrected using MAD/median logic)
      * Total stock cost
  - Handles batch / non-batch items
  - Detects outlier batch costs and adjusts overall unit cost
  - Excludes certain stock groups (108,109,113,114,116) for confidentiality

  Parameters:
    @MAD_FACTOR  : DECIMAL = 3.0   -- multiplier for MAD threshold
    @TOL_PERCENT : DECIMAL = 0.10  -- tolerance when MAD = 0
    @TOL_ABS     : DECIMAL = 0.05  -- minimum absolute tolerance
*/

DECLARE @MAD_FACTOR DECIMAL(10,4)  = 3.0;
DECLARE @TOL_PERCENT DECIMAL(10,4) = 0.10;
DECLARE @TOL_ABS DECIMAL(10,4)     = 0.05;

-- 1) Batch-level stock & cost
WITH BatchTracking AS (
    SELECT 
        'COMPANY' AS Company,
        T2.ItemCode      AS ItemCode,
        T2.ItemName      AS ItemName,
        T2.LocCode       AS Warehouse,
        T4.DistNumber    AS BatchNo,
        SUM(T3.Quantity) AS Quantity,
        CASE WHEN ISNULL(T4.Quantity,0) > 0 THEN T4.CostTotal/T4.Quantity ELSE 0 END AS UnitCost,
        SUM(T3.Quantity) * CASE WHEN ISNULL(T4.Quantity,0) > 0 THEN T4.CostTotal/T4.Quantity ELSE 0 END AS TotalCost,
        T2.ItemGroup     AS ItemGroup,
        T2.ItemSubGroup  AS ItemSubGroup,
        T2.Uom           AS Unit
    FROM BatchLedger T2
    LEFT JOIN BatchLedgerLines T3
        ON T2.LogEntry = T3.LogEntry AND T2.ItemCode = T3.ItemCode
    LEFT JOIN Batches T4
        ON T3.ItemCode = T4.ItemCode AND T3.SysNumber = T4.SysNumber
    WHERE COALESCE(T4.DistNumber,'') <> ''
    GROUP BY T2.ItemCode, T2.LocCode, T4.DistNumber, T4.CostTotal, T4.Quantity,
             T2.ItemName, T2.ItemGroup, T2.ItemSubGroup, T2.Uom
    HAVING SUM(T3.Quantity) > 0
),

-- 2) Median & MAD per item
Median AS (
    SELECT 
        b.*,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.UnitCost)
            OVER (PARTITION BY b.ItemCode) AS MedianCost
    FROM BatchTracking b
),
MAD_Prepared AS (
    SELECT 
        m.*,
        ABS(m.UnitCost - m.MedianCost) AS AD,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ABS(m.UnitCost - m.MedianCost))
            OVER (PARTITION BY m.ItemCode) AS MAD
    FROM Median m
),

-- 3) Flag outliers
Flagged AS (
    SELECT
        x.*,
        CASE 
            WHEN x.MAD IS NULL THEN 1
            WHEN x.MAD = 0 THEN 
                CASE WHEN ABS(x.UnitCost - x.MedianCost) <= COALESCE(@TOL_PERCENT*NULLIF(x.MedianCost,0),@TOL_ABS) THEN 1 ELSE 0 END
            ELSE CASE WHEN x.AD <= @MAD_FACTOR*x.MAD THEN 1 ELSE 0 END
        END AS ValidCost
    FROM MAD_Prepared x
),

-- 4) Corrected unit cost per item
Reference AS (
    SELECT
        ItemCode,
        SUM(CASE WHEN ValidCost=1 THEN Quantity*UnitCost END) /
        NULLIF(SUM(CASE WHEN ValidCost=1 THEN Quantity END),0) AS CorrectedUnitCost
    FROM Flagged
    GROUP BY ItemCode
),

-- 5) Warehouse-level stock (batch + non-batch)
Combined AS (
    SELECT
        'COMPANY' AS Company,
        I.ItemCode,
        I.ItemName,
        W.Warehouse AS Warehouse,
        W.OnHand AS Quantity,
        I.AvgCost AS UnitCost,
        W.OnHand*I.AvgCost AS TotalCost,
        I.ItemGroup,
        I.ItemSubGroup,
        I.Uom
    FROM Items I
    INNER JOIN WarehouseStock W ON I.ItemCode = W.ItemCode
    WHERE I.ManualBatch = 'N' AND W.OnHand>0
    UNION ALL
    SELECT
        Company, ItemCode, ItemName, Warehouse, SUM(Quantity),
        CASE WHEN SUM(Quantity)>0 THEN SUM(TotalCost)/SUM(Quantity) ELSE 0 END,
        SUM(TotalCost), ItemGroup, ItemSubGroup, Unit
    FROM BatchTracking
    GROUP BY Company, ItemCode, ItemName, Warehouse, ItemGroup, ItemSubGroup, Unit
)

-- 6) Final stock cost report
SELECT
    c.Company,
    c.ItemCode,
    c.ItemName,
    c.Warehouse,
    SUM(c.Quantity) AS Quantity,
    COALESCE(r.CorrectedUnitCost, SUM(c.TotalCost)/NULLIF(SUM(c.Quantity),0)) AS UnitCost,
    SUM(c.Quantity)*COALESCE(r.CorrectedUnitCost, SUM(c.TotalCost)/NULLIF(SUM(c.Quantity),0)) AS TotalCost,
    c.ItemGroup,
    c.ItemSubGroup,
    c.Uom
FROM Combined c
LEFT JOIN Reference r ON r.ItemCode = c.ItemCode
GROUP BY c.Company, c.ItemCode, c.ItemName, c.Warehouse, c.ItemGroup, c.ItemSubGroup, c.Uom, r.CorrectedUnitCost
ORDER BY c.ItemCode, c.Warehouse;
