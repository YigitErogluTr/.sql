/*
  Production Cost per Work Order (Actual)
  - Anonymized & parameterized
  - For each production order, computes:
      * Direct total cost from Goods Receipt (OIGN/IGN1, BaseType=202)
      * Direct unit cost = Direct total / Completed quantity
  - Optional date range filter on OWOR.PostDate.

  Parameters:
    @StartDate : DATE = NULL  -- inclusive; set NULL to ignore
    @EndDate   : DATE = NULL  -- inclusive; set NULL to ignore
*/

DECLARE @StartDate DATE = NULL;
DECLARE @EndDate   DATE = NULL;

SELECT
    YEAR(W.PostDate)                                   AS [Year],
    MONTH(W.PostDate)                                  AS [Month],
    W.PostDate                                         AS [PostingDate],
    W.DocNum                                           AS [WorkOrderNo],
    W.ItemCode,
    W.ProdName                                         AS [ProductName],
    W.CmpltQty                                         AS [CompletedQty],
    COALESCE(Costs.TotalCost, 0)                       AS [DirectTotalCost],
    CASE
        WHEN COALESCE(W.CmpltQty, 0) > 0
            THEN COALESCE(Costs.TotalCost, 0) / NULLIF(W.CmpltQty, 0)
        ELSE 0
    END                                                AS [DirectUnitCost]
FROM dbo.OWOR AS W
LEFT JOIN (
    SELECT
        I.BaseRef                                      AS WorkOrderNo,
        SUM(I.Quantity * I.Price)                      AS TotalCost
    FROM dbo.IGN1 AS I
    INNER JOIN dbo.OIGN AS H
        ON H.DocEntry = I.DocEntry
    WHERE I.BaseType = 202  -- production order
    GROUP BY I.BaseRef
) AS Costs
    ON Costs.WorkOrderNo = W.DocNum
WHERE
    W.CmpltQty > 0
    AND W.Status <> 'C'
    AND (
        @StartDate IS NULL OR @EndDate IS NULL
        OR (W.PostDate >= @StartDate AND W.PostDate < DATEADD(DAY, 1, @EndDate))
    )
ORDER BY
    W.PostDate DESC;
