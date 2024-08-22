SELECT 
    date_trunc('day', invoice_date) AS day,
    SUM(total_revenue) AS revenue
FROM 
    sales
WHERE 
    invoice_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 
    day
ORDER BY 
    day ASC;
