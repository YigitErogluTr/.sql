/*
  Business Partner Balances (Anonymized)
  - Safe for public repos: IBAN removed; names masked by default
  - Optional filters for partner type and group

  Parameters:
    @IncludePII      BIT         = 0   -- 0: mask names; 1: show real names
    @CardTypeFilter  NCHAR(1)    = NULL  -- 'C' (Customer), 'S' (Vendor/Supplier), or NULL for all
    @GroupCode       INT         = NULL  -- OCRG.GroupCode filter
    @OnlyActive      BIT         = NULL  -- NULL: all, 1: only active, 0: only frozen
*/

DECLARE @IncludePII     BIT      = 0;
DECLARE @CardTypeFilter NCHAR(1) = NULL;  -- 'C' or 'S'
DECLARE @GroupCode      INT      = NULL;
DECLARE @OnlyActive     BIT      = NULL;

WITH BP AS (
    SELECT
        CASE WHEN T0.frozenFor = 'Y' THEN 'Frozen' ELSE 'Active' END    AS Status,
        T0.CardCode                                                    AS BusinessPartnerCode,
        CASE 
            WHEN @IncludePII = 1 THEN T0.CardName
            ELSE 
                CASE 
                    WHEN T0.CardName IS NULL OR LEN(T0.CardName)=0 THEN T0.CardName
                    ELSE LEFT(T0.CardName, 1) + REPLICATE('*', LEN(T0.CardName)-1)
                END
        END                                                            AS BusinessPartnerName,
        CASE T0.CardType
            WHEN 'C' THEN 'Customer'
            WHEN 'S' THEN 'Supplier'
            ELSE 'Other'
        END                                                             AS PartnerType,
        G.GroupName                                                     AS PartnerGroupName,
        T0.Currency,
        T0.Balance                                                      AS BalanceLC,
        T0.BalanceFC                                                    AS BalanceFC,
        T0.DNotesBal                                                    AS OpenDeliveryNotesBalanceLC,
        T0.DNoteBalFC                                                   AS OpenDeliveryNotesBalanceFC,
        T0.OrdersBal                                                    AS OpenOrdersBalanceLC,
        T0.OrderBalFC                                                   AS OpenOrdersBalanceFC,
        P.PymntGroup                                                    AS PaymentTerms
        -- NOTE: IBAN intentionally omitted for anonymization
    FROM dbo.OCRD AS T0
    INNER JOIN dbo.OCRG AS G
        ON T0.GroupCode = G.GroupCode
    INNER JOIN dbo.OCTG AS P
        ON T0.GroupNum = P.GroupNum
)
SELECT *
FROM BP
WHERE
    (@CardTypeFilter IS NULL OR PartnerType = CASE @CardTypeFilter WHEN 'C' THEN 'Customer' WHEN 'S' THEN 'Supplier' ELSE PartnerType END)
    AND (@GroupCode IS NULL OR @GroupCode = (SELECT GroupCode FROM dbo.OCRG WHERE GroupName = BP.PartnerGroupName))
    AND (
         @OnlyActive IS NULL
         OR (@OnlyActive = 1 AND Status = 'Active')
         OR (@OnlyActive = 0 AND Status = 'Frozen')
    )
ORDER BY
    BalanceLC DESC, BusinessPartnerCode;
