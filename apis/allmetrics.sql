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
    'Can you summarize the metric with current value is ' || 
    CAST(MAX(revenue_last_invoice_date.revenue) AS VARCHAR) || 
    ', it has changed ' ||
    COALESCE(
        CASE
            WHEN MAX(revenue_previous_day.revenue) = 0 THEN 'not available'
            ELSE CAST(ROUND(
                (MAX(revenue_last_invoice_date.revenue) - MAX(revenue_previous_day.revenue)) /
                MAX(revenue_previous_day.revenue) * 100, 2) AS VARCHAR)
        END, 'not available'
    ) ||
    '% from the last captured calculation. Overall its trend had been [' ||
    STRING_AGG(CAST(revenue_last_7_days.revenue AS VARCHAR), ', ' ORDER BY revenue_last_7_days.day ASC) ||
    '].' AS summary
FROM 
    revenue_last_7_days,
    revenue_last_invoice_date,
    revenue_previous_day;


{% endcache %}
{% endreq %}

{% set var =  {
        "headers": { "Authorization" : "Bearer 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" },
        "body" : { "inputs" : "Generate a summary based on the input provided 
   vaule: 20136,
   change: 0.12,
   trend:
     117816.0,
     43284.0,
     53514.0,
     75294.0,
     85902.0,
     7692.0,
     20136.0
   ,
Where value is the total revenue generated 
change is the percentage change in the revenue from last day of invoive to previous day of invoice
trend shows the amount of revenue generated in the last seven days "}
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/facebook/bart-large-cnn', method = 'POST') }}