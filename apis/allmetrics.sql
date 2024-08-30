{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache
),
revenue_last_invoice_date AS (
    SELECT 
        SUM(total_revenue) AS revenue
    FROM 
        sales_cache
    WHERE 
        invoice_date = (SELECT last_invoice_date FROM last_invoice)
),
revenue_previous_day AS (
    SELECT 
        SUM(total_revenue) AS revenue
    FROM 
        sales_cache
    WHERE 
        invoice_date = (SELECT last_invoice_date FROM last_invoice) - INTERVAL '1 day'
),
revenue_last_7_days AS (
    SELECT 
        SUM(total_revenue) AS total_revenue_7_days
    FROM 
        sales_cache
    WHERE 
        invoice_date >= (SELECT last_invoice_date FROM last_invoice) - INTERVAL '7 days'
        AND invoice_date <= (SELECT last_invoice_date FROM last_invoice)
)
SELECT 
    (SELECT revenue FROM revenue_last_invoice_date) AS total_revenue_last_invoice_date,
    ROUND(
        CASE
            WHEN (SELECT revenue FROM revenue_previous_day) = 0 THEN NULL
            ELSE ((SELECT revenue FROM revenue_last_invoice_date) - (SELECT revenue FROM revenue_previous_day)) /
                 (SELECT revenue FROM revenue_previous_day) * 100
        END, 2
    ) AS percentage_change,
    (SELECT total_revenue_7_days FROM revenue_last_7_days) AS total_revenue_7_days;

{% endcache %}

