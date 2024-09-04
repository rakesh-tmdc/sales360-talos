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
        "body" : { "inputs" : "You are an AI analyst tasked with providing a concise summary of metric trends. You will be given information about a specific metric, and your job is to analyze the data and provide a brief, insightful summary focusing on any notable trends, spikes, or anomalies. Your summary should be approximately 2-3 sentences long and written in a clear, professional tone.
Here's the data for analysis:

Metric Name: {Total Revenue}
Data Product: {Revenue}
Domain: {Sales}
Use cases: {Assess financial performance, Identify sales trends, Evaluate the effectiveness of marketing campaigns}
Current value: {$20,136}
Time granularity: {Daily}
Last value timestamp: Aug 14, 2024
Recent trend (7 days): {[117,816, 43,284, 53,514, 75,294, 85,902, 7,692, 20,136]}

Please provide a concise summary of the metric's performance, highlighting any significant trends, spikes, or anomalies along with the dates when they occurred. Focus on the current value, the change from the previous period, and the recent trend within the specified date range. If relevant, briefly mention how this might impact the stated use cases."}
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/facebook/bart-large-cnn', method = 'POST') }} as result