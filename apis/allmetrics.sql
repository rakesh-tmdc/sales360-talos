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
    'The trend of the last 7 days is ' || 
    STRING_AGG(CAST(revenue AS VARCHAR), ', ' ORDER BY day ASC) || 
    '. The percentage change is ' ||
    COALESCE(
        ROUND(
            CASE
                WHEN (SELECT SUM(total_revenue) FROM revenue_previous_day) = 0 THEN NULL
                ELSE (
                    (SELECT SUM(total_revenue) FROM revenue_last_invoice_date) - 
                    (SELECT SUM(total_revenue) FROM revenue_previous_day)
                ) / (SELECT SUM(total_revenue) FROM revenue_previous_day) * 100
            END, 2
        ), 'not available'
    ) ||
    '. The total revenue of the last invoice date is ' ||
    CAST((SELECT SUM(total_revenue) FROM revenue_last_invoice_date) AS VARCHAR) || 
    '.' AS summary
FROM 
    revenue_last_7_days;


{% endcache %}
{% endreq %}
{% set var =  {
        "headers": { "Authorization" : "Bearer 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" },
        "body" : { "inputs" : summary.value() | string |list }
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/gpt2', method = 'POST') }}