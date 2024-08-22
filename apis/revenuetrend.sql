WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales
)
SELECT 
    date_trunc('day', invoice_date) AS day,
    SUM(total_revenue) AS revenue
FROM 
    sales, last_invoice
WHERE 
    invoice_date >= last_invoice.last_invoice_date - INTERVAL '7 days'
    AND invoice_date <= last_invoice.last_invoice_date
GROUP BY 
    day
ORDER BY 
    day ASC;
