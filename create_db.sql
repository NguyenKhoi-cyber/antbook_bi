-- 1. Top 10 best-selling books in the last 30 days (by quantity and revenue)
SELECT 
    pt.name AS book_title,
    SUM(sol.product_uom_qty) AS total_qty_sold,
    SUM(sol.price_total) AS total_revenue
FROM sale_order_line sol
JOIN sale_order so ON sol.order_id = so.id
JOIN product_product pp ON sol.product_id = pp.id
JOIN product_template pt ON pp.product_tmpl_id = pt.id
WHERE so.state IN ('sale', 'done') 
  AND so.date_order >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Current stock valuation by warehouse (real-time inventory value)
SELECT 
    sw.name AS warehouse,
    pc.name AS category,
    SUM(sq.quantity * pp.standard_price) AS inventory_value_vnd
FROM stock_quant sq
JOIN stock_location sl ON sq.location_id = sl.id
JOIN stock_warehouse sw ON sl.complete_name LIKE sw.complete_name || '%'
JOIN product_product pp ON sq.product_id = pp.id
JOIN product_template pt ON pp.product_tmpl_id = pt.id
JOIN product_category pc ON pt.categ_id = pc.id
WHERE sl.usage = 'internal'
GROUP BY sw.name, pc.name
ORDER BY inventory_value_vnd DESC;

--3. Lead-to-Customer conversion rate by salesperson (last quarter)
WITH lead_data AS (
    SELECT 
        s.user_id,
        COUNT(*) FILTER (WHERE c.stage_id = 1) AS total_leads,  -- Stage 1 = New
        COUNT(*) FILTER (WHERE c.stage_id = 4 OR so.id IS NOT NULL) AS converted
    FROM crm_lead c
    LEFT JOIN sale_order so ON c.id = so.opportunity_id AND so.state IN ('sale','done')
    LEFT JOIN res_users s ON c.user_id = s.id
    WHERE c.create_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY s.user_id
)
SELECT 
    ru.login AS salesperson,
    total_leads,
    converted,
    ROUND(100.0 * converted / NULLIF(total_leads,0), 2) || '%' AS conversion_rate
FROM lead_data ld
JOIN res_users ru ON ld.user_id = ru.id
ORDER BY conversion_rate DESC;

--4. Aging Accounts Receivable
SELECT 
    rp.name AS customer,
    am.date_due,
    am.amount_residual AS outstanding_vnd,
    CURRENT_DATE - am.date_due AS days_overdue
FROM account_move am
JOIN res_partner rp ON am.partner_id = rp.id
WHERE am.move_type = 'out_invoice'
  AND am.payment_state IN ('not_paid', 'partial')
  AND am.state = 'posted'
ORDER BY days_overdue DESC;

--5. End-to-end traceability: From Lead → Sales Order → Delivery → Invoice → Payment
SELECT 
    c.name AS lead_name,
    c.create_date AS lead_date,
    so.name AS sales_order,
    so.date_order,
    sp.name AS delivery_order,
    sp.scheduled_date,
    ai.name AS invoice_number,
    ai.invoice_date,
    ap.date AS payment_date,
    ap.amount
FROM crm_lead c
LEFT JOIN sale_order so ON c.id = so.opportunity_id
LEFT JOIN stock_picking sp ON sp.sale_id = so.id AND sp.picking_type_code = 'outgoing'
LEFT JOIN account_move ai ON ai.move_type = 'out_invoice' AND ai.invoice_origin = so.name
LEFT JOIN account_payment ap ON ap.ref = ai.name
WHERE c.name = 'LEAD/2025/12/00012';

--6. Low-stock alert + automatic reorder recommendation
SELECT 
    pt.name AS book,
    sq.quantity AS current_stock,
    pt.min_stock_rule AS min_threshold,
    (pt.min_stock_rule - sq.quantity) * pp.standard_price AS estimated_purchase_value_vnd
FROM product_template pt
JOIN product_product pp ON pt.id = pp.product_tmpl_id
JOIN stock_quant sq ON pp.id = sq.product_id
JOIN stock_location sl ON sq.location_id = sl.id
WHERE sl.usage = 'internal'
  AND sq.quantity < pt.min_stock_rule
  AND pt.active = true
ORDER BY estimated_purchase_value_vnd DESC;