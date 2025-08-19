SELECT TOP 1 
    T1.Price
FROM 
    OINV T0
    INNER JOIN INV1 T1 ON T0.DocEntry = T1.DocEntry
WHERE 
    T0.CardCode = $[$4.0]          -- formdaki cari kodu (BP Code) alır
    AND T1.ItemCode = $[$38.1.0]   -- formdaki stok kodunu alır
ORDER BY 
    T0.DocDate DESC                -- en güncel fatura fiyatını getirir
