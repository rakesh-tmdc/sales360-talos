{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache1
),
revenue_last_7_days AS (
    SELECT 
        SUM(total_revenue) AS revenue
    FROM 
        sales_cache1, last_invoice
    WHERE 
        invoice_date > last_invoice.last_invoice_date - INTERVAL '7 days'
        AND invoice_date <= last_invoice.last_invoice_date
),
revenue_previous_7_days AS (
    SELECT 
        SUM(total_revenue) AS revenue
    FROM 
        sales_cache1, last_invoice
    WHERE 
        invoice_date > last_invoice.last_invoice_date - INTERVAL '14 days'
        AND invoice_date <= last_invoice.last_invoice_date - INTERVAL '7 days'
)
SELECT 
    CASE
        WHEN revenue_previous_7_days.revenue = 0 THEN NULL
        ELSE ROUND(((revenue_last_7_days.revenue - revenue_previous_7_days.revenue) / revenue_previous_7_days.revenue) * 100, 2)
    END AS percentage_change
FROM 
    revenue_last_7_days, revenue_previous_7_days;
{% endcache %}    
