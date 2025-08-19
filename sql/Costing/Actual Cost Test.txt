/*
  Actual Production Cost by Work Order (Monthly overhead allocation)
  - Anonymized & parameterized for public use
  - Allocates monthly G/L expense groups (720..780) to each work order
    proportionally to its completed quantity in that month.

  Parameters:
    @Year : INT  -- target calendar year (e.g., 2025)

  Notes:
  - Table names (OWOR, OIGN, IGN1, OJDT, JDT1) follow standard SAP B1 schema.
  - Adjust account group prefixes as needed in CTE_T2 (currently 720..780, 710 excluded).
*/

DECLARE @Year INT = 2025;

WITH
-- 1) Per-work-order direct cost (based on production receipts)
CTE_T0 AS (
    SELECT
        YEAR(W.PostDate)                                  AS [Year],
        MONTH(W.PostDate)                                 AS [Month],
        W.DocNum                                          AS WorkOrderNo,
        W.ItemCode,
        W.ProdName                                        AS ProductName,
        W.CmpltQty                                        AS ProducedQty,
        COALESCE(M.TotalCost, 0)                          AS DirectCostTotal,
        CASE
            WHEN W.CmpltQty > 0
                THEN COALESCE(M.TotalCost, 0) * 1.0 / W.CmpltQty
            ELSE 0
        END                                               AS DirectUnitCost
    FROM dbo.OWOR AS W
    LEFT JOIN (
        SELECT
            I.BaseRef                                     AS WorkOrderNo,
            SUM(I.Quantity * I.Price)                     AS TotalCost
        FROM dbo.IGN1 AS I
        INNER JOIN dbo.OIGN AS H
            ON H.DocEntry = I.DocEntry
        WHERE I.BaseType = 202  -- production order
        GROUP BY I.BaseRef
    ) AS M
        ON M.WorkOrderNo = W.DocNum
    WHERE
        W.CmpltQty > 0
        AND W.Status <> 'C'
        AND YEAR(W.PostDate) = @Year
),

-- 2) Monthly total produced quantity (for proportional allocation base)
CTE_T1 AS (
    SELECT
        YEAR(PostDate)            AS [Year],
        MONTH(PostDate)           AS [Month],
        SUM(CmpltQty)             AS MonthlyProducedQty
    FROM dbo.OWOR
    WHERE
        CmpltQty > 0
        AND Status <> 'C'
        AND YEAR(PostDate) = @Year
    GROUP BY YEAR(PostDate), MONTH(PostDate)
),

-- 3) Monthly G/L expenses by 3-digit account group (exclude 710)
CTE_T2 AS (
    SELECT
        YEAR(J.RefDate)           AS [Year],
        MONTH(J.RefDate)          AS [Month],
        LEFT(D.Account, 3)        AS AccountGroup,
        SUM(D.Debit - D.Credit)   AS Amount
    FROM dbo.OJDT AS J
    INNER JOIN dbo.JDT1 AS D
        ON J.TransId = D.TransId
    WHERE
        YEAR(J.RefDate) = @Year
        AND LEFT(D.Account, 3) IN ('720','730','740','750','760','770','780')
    GROUP BY YEAR(J.RefDate), MONTH(J.RefDate), LEFT(D.Account, 3)
),

-- 4) Pivot-like monthly totals for faster joins
CTE_T2_PIVOT AS (
    SELECT
        [Year],
        [Month],
        SUM(CASE WHEN AccountGroup = '720' THEN Amount ELSE 0 END) AS Exp_720,
        SUM(CASE WHEN AccountGroup = '730' THEN Amount ELSE 0 END) AS Exp_730,
        SUM(CASE WHEN AccountGroup = '740' THEN Amount ELSE 0 END) AS Exp_740,
        SUM(CASE WHEN AccountGroup = '750' THEN Amount ELSE 0 END) AS Exp_750,
        SUM(CASE WHEN AccountGroup = '760' THEN Amount ELSE 0 END) AS Exp_760,
        SUM(CASE WHEN AccountGroup = '770' THEN Amount ELSE 0 END) AS Exp_770,
        SUM(CASE WHEN AccountGroup = '780' THEN Amount ELSE 0 END) AS Exp_780
    FROM CTE_T2
    GROUP BY [Year], [Month]
)

SELECT
    T0.[Year],
    T0.[Month],
    T0.WorkOrderNo,
    T0.ItemCode,
    T0.ProductName,
    T0.ProducedQty,
    T0.DirectCostTotal,
    T0.DirectUnitCost,
    COALESCE(T1.MonthlyProducedQty, 1) AS MonthlyProducedQty,

    -- Allocated overhead per work order (per account group)
    COALESCE(T2.Exp_720, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_720,
    COALESCE(T2.Exp_730, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_730,
    COALESCE(T2.Exp_740, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_740,
    COALESCE(T2.Exp_750, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_750,
    COALESCE(T2.Exp_760, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_760,
    COALESCE(T2.Exp_770, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_770,
    COALESCE(T2.Exp_780, 0) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_780,

    -- Total allocated overhead
    (
        COALESCE(T2.Exp_720, 0) +
        COALESCE(T2.Exp_730, 0) +
        COALESCE(T2.Exp_740, 0) +
        COALESCE(T2.Exp_750, 0) +
        COALESCE(T2.Exp_760, 0) +
        COALESCE(T2.Exp_770, 0) +
        COALESCE(T2.Exp_780, 0)
    ) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS Alloc_Total,

    -- Actual total cost = direct cost + allocated overhead
    T0.DirectCostTotal +
    (
        COALESCE(T2.Exp_720, 0) +
        COALESCE(T2.Exp_730, 0) +
        COALESCE(T2.Exp_740, 0) +
        COALESCE(T2.Exp_750, 0) +
        COALESCE(T2.Exp_760, 0) +
        COALESCE(T2.Exp_770, 0) +
        COALESCE(T2.Exp_780, 0)
    ) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0) AS ActualTotalCost,

    -- Actual unit cost
    CASE
        WHEN T0.ProducedQty > 0 THEN
            (
                T0.DirectCostTotal +
                (
                    COALESCE(T2.Exp_720, 0) +
                    COALESCE(T2.Exp_730, 0) +
                    COALESCE(T2.Exp_740, 0) +
                    COALESCE(T2.Exp_750, 0) +
                    COALESCE(T2.Exp_760, 0) +
                    COALESCE(T2.Exp_770, 0) +
                    COALESCE(T2.Exp_780, 0)
                ) * T0.ProducedQty / NULLIF(COALESCE(T1.MonthlyProducedQty, 1), 0)
            ) / T0.ProducedQty
        ELSE 0
    END AS ActualUnitCost
FROM CTE_T0 AS T0
LEFT JOIN CTE_T1 AS T1
    ON T1.[Year] = T0.[Year]
   AND T1.[Month] = T0.[Month]
LEFT JOIN CTE_T2_PIVOT AS T2
    ON T2.[Year] = T0.[Year]
   AND T2.[Month] = T0.[Month]
ORDER BY
    T0.[Year], T0.[Month], T0.WorkOrderNo;
