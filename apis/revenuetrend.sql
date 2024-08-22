{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache
)
SELECT 
    date_trunc('day', invoice_date) AS day,
    SUM(total_revenue) AS revenue
FROM 
    sales_cache, last_invoice
WHERE 
    invoice_date >= last_invoice.last_invoice_date - INTERVAL '7 days'
    AND invoice_date <= last_invoice.last_invoice_date
GROUP BY 
    day
ORDER BY 
    day ASC;
{% end_cache %}    

