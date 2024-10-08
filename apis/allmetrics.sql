{% req summary %}
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
        date_trunc('day', invoice_date) AS day,
        SUM(total_revenue) AS revenue
    FROM 
        sales_cache
    WHERE 
        invoice_date >= (SELECT last_invoice_date FROM last_invoice) - INTERVAL '7 days'
        AND invoice_date <= (SELECT last_invoice_date FROM last_invoice)
    GROUP BY 
        day
    ORDER BY 
        day ASC
)
SELECT 
    MAX(revenue_last_invoice_date.revenue) AS value,
    ROUND(
        CASE
            WHEN MAX(revenue_previous_day.revenue) = 0 THEN NULL
            ELSE (MAX(revenue_last_invoice_date.revenue) - MAX(revenue_previous_day.revenue)) /
                 MAX(revenue_previous_day.revenue) * 100
        END, 2
    ) AS change,
    STRING_AGG(CAST(revenue_last_7_days.revenue AS VARCHAR), ', ' ORDER BY revenue_last_7_days.day ASC) AS trend
FROM 
    revenue_last_7_days,
    revenue_last_invoice_date,
    revenue_previous_day;



{% endcache %}
{% endreq %}

