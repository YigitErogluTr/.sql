/* Inventory Transactions Report */

SELECT
    i.TransNum       AS TransactionNumber,
    i.TransType      AS TransactionType,
    i.DocDate        AS PostingDate,
    i.DocDueDate     AS DueDate,
    i.CardCode       AS BusinessPartnerCode,
    i.CardName       AS BusinessPartnerName,
    i.Ref2           AS Reference2,
    i.JrnlMemo       AS JournalRemarks,
    i.ItemCode       AS ItemCode,
    i.Dscription     AS ItemDescription,
    i.InQty          AS QuantityIn,
    i.OutQty         AS QuantityOut,
    i.Price          AS UnitPrice,
    i.Currency       AS Currency,
    i.Warehouse      AS WarehouseCode,
    i.TaxDate        AS DocumentDate,
    i.CalcPrice      AS CalculatedPrice,
    i.CostAct        AS CogsAccount,
    i.TransValue     AS TransactionValue,
    i.StockAct       AS StockAccount,
    i.OpenValue      AS OpenValue,
    i.CogsVal        AS CogsValue
FROM dbo.OINM AS i
WHERE i.DocDate BETWEEN [%0] AND [%1];
