{% cache %}
WITH last_invoice AS (
    SELECT 
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales_cache
),
revenue_last_invoice_date AS (
    SELECT 
        total_revenue AS revenue
    FROM 
        sales_cache, last_invoice
    WHERE 
        invoice_date = last_invoice.last_invoice_date
),
revenue_previous_day AS (
    SELECT 
        total_revenue AS revenue
    FROM 
        sales_cache, last_invoice
    WHERE 
        invoice_date = last_invoice.last_invoice_date - INTERVAL '1 day'
),
revenue_trend AS (
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
        day ASC
)
SELECT 
    -- Total revenue on the last invoice date
    (SELECT revenue FROM revenue_last_invoice_date) AS total_revenue_last_invoice_date,

    -- Percentage change in revenue between the last invoice date and the previous day
    ROUND(
        CASE
            WHEN (SELECT revenue FROM revenue_previous_day) = 0 THEN NULL
            ELSE ((SELECT revenue FROM revenue_last_invoice_date) - (SELECT revenue FROM revenue_previous_day)) /
                 (SELECT revenue FROM revenue_previous_day) * 100
        END, 2
    ) AS percentage_change,

    -- Revenue trend over the last 7 days
    day,
    revenue
FROM 
    revenue_trend;
{% endcache %}

