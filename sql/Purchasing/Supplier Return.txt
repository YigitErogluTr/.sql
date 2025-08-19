-- Supplier Return Report
-- Shows return documents with item, supplier, pricing, and base document details

SELECT  
    RT.DocEntry,  
    RTL.ItemCode       AS [Product Code],  
    RTL.Dscription     AS [Product Name],  
    RT.NumAtCard       AS [Supplier Ref No],  
    RT.U_H1_eIrsaliyeNo AS [E-Dispatch No],  
    RT.CardName        AS [Supplier Name],  
    RTL.Quantity       AS [Return Quantity],  
    RTL.UomCode        AS [Unit],  
    RTL.Price          AS [Return Unit Price],  
    RTL.Currency       AS [Currency],  
    RTL.Rate           AS [Exchange Rate],  

    -- Local currency calculation (TRY)
    CAST(  
        RTL.Quantity * RTL.Price *  
        CASE  
            WHEN RTL.Currency = 'TRY' OR ISNULL(RTL.Rate, 0) = 0 THEN 1  
            ELSE RTL.Rate  
        END  
        AS DECIMAL(18,2)  
    ) AS [Total Amount (LC)],  

    RT.DocDate         AS [Return Date],  
    RTL.InvQty         AS [Inventory Quantity],  
    RTL.UomCode2       AS [Inventory Unit],  

    CASE  
        WHEN RTL.BaseType = 20 THEN 'AP Invoice'  
        WHEN RTL.BaseType = 234000032 THEN 'Return Request'  
        ELSE CAST(RTL.BaseType AS VARCHAR)  
    END AS [Base Document Type],  

    RTL.BaseEntry      AS [Base Document No],  
    U1.U_NAME          AS [Created By User]  

FROM  
    ORPD RT  
    INNER JOIN RPD1 RTL ON RT.DocEntry = RTL.DocEntry  
    LEFT JOIN OUSR U1 ON RT.UserSign = U1.USERID  

WHERE  
    RT.CANCELED = 'N'  

ORDER BY  
    RT.DocDate DESC,  
    RT.DocNum;
