{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache2
)
SELECT 
    measure(total_revenue) AS total_revenue
FROM 
    sales_cache2, last_invoice
WHERE 
    invoice_date = last_invoice.last_invoice_date;
{% endcache %}