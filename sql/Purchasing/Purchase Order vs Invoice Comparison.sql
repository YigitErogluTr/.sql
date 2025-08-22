/*
  Purchase Order vs Invoice Comparison
  ------------------------------------
  - Header: OPOR (Purchase Orders), OPCH (AP Invoices), OPDN (GRPO)
  - Lines : POR1 (PO Lines),  PCH1 (AP Inv Lines), PDN1 (GRPO Lines)
  - Items : OITM

  For each PO line, this shows:
    * PO basics (qty, unit price, currency/rate, UoM)
    * Related GRPO (if any)
    * Related AP Invoice (either via GRPO or directly from PO)
    * Invoice qty/price/currency/rate/UoM (from whichever path exists)

  Notes:
  - COALESCE() is used to prefer invoice attributes from the GRPO→AP path,
    otherwise it falls back to the direct PO→AP path.
*/

SELECT
    PO.DocEntry                                        AS [POEntry],
    POL.ItemCode                                       AS [ItemCode],
    ITM.ItemName                                       AS [ItemName],

    POL.Quantity                                       AS [POQuantity],
    POL.Price                                          AS [POUnitPrice],
    PO.DocCur                                          AS [POCurrency],
    PO.DocRate                                         AS [POFxRate],
    POL.UomCode                                        AS [POUoM],

    -- Goods Receipt PO (if PO line was received)
    PDN.DocEntry                                       AS [GRPOEntry],

    -- Invoice info (via GRPO first, else directly from PO)
    COALESCE(INV_GRPO.DocEntry, INV_DIR.DocEntry)      AS [APInvoiceEntry],
    COALESCE(INVL_GRPO.Quantity, INVL_DIR.Quantity)    AS [APInvoiceQuantity],
    COALESCE(INVL_GRPO.Price,    INVL_DIR.Price)       AS [APInvoiceUnitPrice],
    COALESCE(INV_GRPO.DocCur,    INV_DIR.DocCur)       AS [APInvoiceCurrency],
    COALESCE(INV_GRPO.DocRate,   INV_DIR.DocRate)      AS [APInvoiceFxRate],
    COALESCE(INVL_GRPO.UomCode,  INVL_DIR.UomCode)     AS [APInvoiceUoM],

    ITM.InvntryUom                                     AS [InventoryUoM]

FROM dbo.OPOR  AS PO
INNER JOIN dbo.POR1 AS POL
        ON PO.DocEntry = POL.DocEntry

LEFT JOIN dbo.OITM AS ITM
       ON POL.ItemCode = ITM.ItemCode

-- =============== GRPO link (optional) =================
LEFT JOIN dbo.PDN1 AS PDNL
       ON POL.DocEntry = PDNL.BaseEntry
      AND POL.LineNum  = PDNL.BaseLine
      AND PDNL.BaseType = 22                 -- 22 = Purchase Order
LEFT JOIN dbo.OPDN AS PDN
       ON PDNL.DocEntry = PDN.DocEntry

-- =============== AP Invoice via GRPO ==================
LEFT JOIN dbo.PCH1 AS INVL_GRPO
       ON PDNL.DocEntry = INVL_GRPO.BaseEntry
      AND PDNL.LineNum  = INVL_GRPO.BaseLine
      AND INVL_GRPO.BaseType = 20           -- 20 = GRPO
LEFT JOIN dbo.OPCH AS INV_GRPO
       ON INVL_GRPO.DocEntry = INV_GRPO.DocEntry

-- =============== AP Invoice directly from PO ==========
LEFT JOIN dbo.PCH1 AS INVL_DIR
       ON POL.DocEntry = INVL_DIR.BaseEntry
      AND POL.LineNum  = INVL_DIR.BaseLine
      AND INVL_DIR.BaseType = 22            -- 22 = Purchase Order
LEFT JOIN dbo.OPCH AS INV_DIR
       ON INVL_DIR.DocEntry = INV_DIR.DocEntry

ORDER BY
    PO.DocEntry,
    POL.LineNum;
