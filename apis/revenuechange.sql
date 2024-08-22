{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache1
),
revenue_last_invoice_date AS (
    SELECT 
        total_revenue AS revenue
    FROM 
        sales_cache1, last_invoice
    WHERE 
        invoice_date = last_invoice.last_invoice_date
),
revenue_previous_day AS (
    SELECT 
        total_revenue AS revenue
    FROM 
        sales_cache1, last_invoice
    WHERE 
        invoice_date = last_invoice.last_invoice_date - INTERVAL '1 day'
)
SELECT 
    CASE
        WHEN revenue_previous_day.revenue = 0 THEN 0
        ELSE ROUND(((revenue_last_invoice_date.revenue - revenue_previous_day.revenue) / revenue_previous_day.revenue) * 100, 2)
    END AS percentage_change
FROM 
    revenue_last_invoice_date, revenue_previous_day;

{% endcache %}    
