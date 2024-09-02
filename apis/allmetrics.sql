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
    (SELECT revenue FROM revenue_last_invoice_date) AS total_revenue_last_invoice_date,
    ROUND(
        CASE
            WHEN (SELECT revenue FROM revenue_previous_day) = 0 THEN NULL
            ELSE ((SELECT revenue FROM revenue_last_invoice_date) - (SELECT revenue FROM revenue_previous_day)) /
                 (SELECT revenue FROM revenue_previous_day) * 100
        END, 2
    ) AS percentage_change,
    LIST(revenue ORDER BY day ASC) AS trend_last_7_days
FROM 
    revenue_last_7_days;

{% endcache %}
{% endreq %}

{% set query_result = {
    "total_revenue_last_invoice_date": 20136,
    "percentage_change": null,
    "trend_last_7_days": [117816, 43284, 53514, 75294, 85902, 7692, 20136]
} %}
{% set var =  {
        "headers": { "Authorization" : "Bearer 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" },
        "body" : { "inputs" : query_result }
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/facebook/bart-large-cnn', method = 'POST') }}