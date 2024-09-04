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
        "body" : { "inputs" : "The total revenue for the last invoice date is 20,136. The percentage change from the last recorded value is not available. The revenue trend over the last 7 days shows significant fluctuations, with the following historical values: 117,816, 43,284, 53,514, 75,294, 85,902, 7,692, and 20,136. The trend indicates a sharp decline from an initial high value of 117,816 to the latest value of 20,136, with notable decreases and fluctuations in between. Please provide a summary."}
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/facebook/bart-large-cnn', method = 'POST') }}