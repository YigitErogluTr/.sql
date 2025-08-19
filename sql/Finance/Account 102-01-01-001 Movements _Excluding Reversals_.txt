/*
  Journal Entries with Account Filter
  - Anonymized & parameterized
  - Returns journal entries and their lines for a given GL account
  - Excludes reversing entries (LineMemo NOT LIKE '%Reverse%')

  Parameters:
    @AccountCode : NVARCHAR (GL account code to filter)
*/

DECLARE @AccountCode NVARCHAR(50) = N'XXXX-XX-XX-XXX';  -- replace with target account

SELECT
    T0.Number         AS EntryNumber,
    T0.RefDate        AS PostingDate,
    T0.Memo           AS Remarks,
    T0.BaseRef        AS SourceRef,
    T1.ContraAct      AS ContraAccount,
    T1.LineMemo       AS LineDetails,
    T1.Credit         AS CreditAmount,
    T1.Debit          AS DebitAmount,
    T1.Account        AS AccountCode
FROM dbo.OJDT AS T0
INNER JOIN dbo.JDT1 AS T1
    ON T1.TransId = T0.TransId
WHERE
    T1.Account = @AccountCode
    AND T1.LineMemo NOT LIKE N'%Reverse%'
ORDER BY
    T0.RefDate DESC,
    T0.Number;
