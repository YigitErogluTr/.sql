-- Goods Return Document Detail Report
-- Header (ORDN) + Line (RDN1)

SELECT  
    H.DocEntry            AS [Document Number],  
    H.DocStatus           AS [Document Status],  
    H.TaxDate             AS [Document Date],  
    H.DocDate             AS [Posting Date],  
    H.U_H1_BelgeTipi      AS [Sales Document Type],  
    H.CardCode            AS [Customer/Vendor Code],  
    H.CardName            AS [Customer/Vendor Name],  
    H.ShipToCode          AS [Ship-To Code],  
    H.NumAtCard           AS [Customer Reference No],  
    H.U_AIF_ET_OrderNo    AS [Order No],  
    H.U_H1_eIrsaliyeNo    AS [e-Dispatch No],  
    H.U_EFATNO            AS [e-Invoice ID],  

    L.ItemCode            AS [Item Code],  
    L.Dscription          AS [Item/Service Description],  
    L.Quantity            AS [Quantity],  
    L.UomCode             AS [Unit of Measure Code],  
    L.U_PaketAdedi        AS [Package Quantity],  
    L.Price               AS [Unit Price],  
    L.LineTotal           AS [Line Total],  
    L.VatSum              AS [Tax Amount],  
    L.PriceAfVAT          AS [Total with Tax],  

    H.U_AIF_ET_CarCompCode AS [Carrier Company Code],  
    H.U_AIF_ET_CarCompName AS [Carrier Company Name],  

    L.BaseRef             AS [Base Document Reference],  
    H.Comments            AS [Remarks]  

FROM  
    RDN1 L   -- Goods Return Lines  
    INNER JOIN ORDN H ON H.DocEntry = L.DocEntry;  -- Goods Return Header
