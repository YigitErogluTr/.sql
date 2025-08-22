/* Purchasing Process Chain Report (Request → Quotation → PO → GRPO → AP Invoice) */

SELECT
    -- Request
    prq.DocNum                                   AS request_no,
    prq.CreateDate                               AS request_created_at,
    prq.DocDate                                  AS request_date,
    prq.ReqDate                                  AS request_due_date,
    prq.ReqName                                  AS requester_name,
    prl.ItemCode                                 AS request_item_code,
    prl.Dscription                               AS request_item_name,
    prl.Quantity                                 AS request_qty,
    prl.Price                                    AS request_unit_price,
    prl.Currency                                 AS request_currency,
    prl.WhsCode                                  AS request_warehouse,
    prl.[Text]                                   AS request_line_note,
    prq.Comments                                 AS request_header_note,
    CASE prq.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END
                                                     AS request_status,
    CASE prq.CANCELED  WHEN 'Y' THEN 'Cancelled' ELSE '' END
                                                     AS request_cancel_flag,

    -- Quotation
    pqt.DocNum                                   AS quotation_no,
    pqt.CreateDate                               AS quotation_created_at,
    pqt.DocDate                                  AS quotation_date,
    pqt.DocDueDate                               AS quotation_valid_until,
    pqtl.ItemCode                                AS quotation_item_code,
    pqtl.Dscription                              AS quotation_item_name,
    pqtl.Quantity                                AS quotation_qty,
    pqtl.Price                                   AS quotation_unit_price,
    pqtl.WhsCode                                 AS quotation_warehouse,
    pqtl.Currency                                AS quotation_currency,
    pqt.Comments                                 AS quotation_header_note,
    CASE pqt.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END
                                                     AS quotation_status,
    CASE pqt.CANCELED  WHEN 'Y' THEN 'Cancelled' ELSE '' END
                                                     AS quotation_cancel_flag,

    -- Purchase Order
    po.DocNum                                    AS po_no,
    po.CreateDate                                AS po_created_at,
    po.DocDate                                   AS po_date,
    po.DocDueDate                                AS planned_delivery_date,
    pol.Quantity                                 AS po_qty,
    pol.Price                                    AS po_unit_price,
    pol.Currency                                 AS po_currency,
    pol.WhsCode                                  AS po_warehouse,
    po.Comments                                  AS po_header_note,
    CASE po.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END
                                                     AS po_status,
    CASE po.CANCELED  WHEN 'Y' THEN 'Cancelled' ELSE '' END
                                                     AS po_cancel_flag,

    -- Goods Receipt PO
    grpo.DocNum                                  AS grpo_no,
    grpo.CreateDate                              AS grpo_created_at,
    grpo.TaxDate                                 AS grpo_actual_receipt_date,
    grpol.Quantity                               AS grpo_qty,
    grpol.Price                                  AS grpo_unit_price,
    grpol.Currency                               AS grpo_currency,
    grpol.WhsCode                                AS grpo_warehouse,
    grpo.U_H1_eIrsaliyeNo                        AS grpo_e_despatch_no,
    CASE grpo.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END
                                                     AS grpo_status,
    CASE grpo.CANCELED WHEN 'Y' THEN 'Cancelled' ELSE '' END
                                                     AS grpo_cancel_flag,

    -- AP Invoice
    ap.DocNum                                    AS ap_invoice_no,
    ap.CreateDate                                AS ap_invoice_created_at,
    ap.TaxDate                                   AS ap_invoice_date,
    ap.DocDueDate                                AS ap_payment_due_date,
    apl.Quantity                                 AS ap_qty,
    apl.Price                                    AS ap_unit_price,
    apl.Currency                                 AS ap_currency,
    ap.NumAtCard                                 AS ap_vendor_ref_no,
    CASE ap.DocStatus WHEN 'O' THEN 'Open' WHEN 'C' THEN 'Closed' END
                                                     AS ap_status,
    CASE ap.CANCELED WHEN 'Y' THEN 'Cancelled' ELSE '' END
                                                     AS ap_cancel_flag,

    -- Item & grouping
    itg.ItmsGrpNam                               AS item_group_name,
    itm.U_stokkodgrup                            AS item_code_group,
    pol.ItemCode                                 AS item_code,
    pol.Dscription                               AS item_name,
    pol.UomCode                                  AS item_uom,

    -- Vendor & buyer
    po.CardCode                                  AS vendor_code,
    po.CardName                                  AS vendor_name,
    slp.SlpName                                  AS buyer_name

FROM
    OPOR AS po
    INNER JOIN POR1  AS pol  ON po.DocEntry = pol.DocEntry

    -- Quotation link (Purchase Quotation)
    LEFT  JOIN PQT1  AS pqtl
        ON  pol.BaseType = 540000006
        AND pol.BaseEntry = pqtl.DocEntry
        AND pol.BaseLine  = pqtl.LineNum
    LEFT  JOIN OPQT  AS pqt   ON pqtl.DocEntry = pqt.DocEntry

    -- Request link (supports request coming via PO or via quotation)
    LEFT  JOIN PRQ1  AS prl
        ON (
               pol.BaseType = 1470000113 AND pol.BaseEntry = prl.DocEntry AND pol.BaseLine = prl.LineNum
           )
        OR (
               pqtl.BaseType = 1470000113 AND pqtl.BaseEntry = prl.DocEntry AND pqtl.BaseLine = prl.LineNum
           )
    LEFT  JOIN OPRQ  AS prq   ON prl.DocEntry = prq.DocEntry

    -- GRPO link
    LEFT  JOIN PDN1  AS grpol
        ON  grpol.BaseType = 22
        AND grpol.BaseEntry = pol.DocEntry
        AND grpol.BaseLine  = pol.LineNum
    LEFT  JOIN OPDN  AS grpo  ON grpo.DocEntry = grpol.DocEntry

    -- AP Invoice link (via GRPO)
    LEFT  JOIN PCH1  AS apl
        ON  apl.BaseType  = 20
        AND apl.BaseEntry = grpol.DocEntry
        AND apl.BaseLine  = grpol.LineNum
    LEFT  JOIN OPCH  AS ap    ON ap.DocEntry = apl.DocEntry

    -- Item master & group
    LEFT  JOIN OITM  AS itm   ON pol.ItemCode = itm.ItemCode
    LEFT  JOIN OITB  AS itg   ON itm.ItmsGrpCod = itg.ItmsGrpCod

    -- Buyer (PO owner)
    LEFT  JOIN OSLP  AS slp   ON po.SlpCode = slp.SlpCode

ORDER BY
    po.DocNum, grpo.DocNum, ap.DocNum, pqt.DocNum;
