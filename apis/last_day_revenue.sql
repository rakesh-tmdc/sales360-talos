SELECT 
    measure(total_revenue)
FROM 
    sales
WHERE 
    invoice_date = (SELECT last_invoice_date FROM last_invoice) - INTERVAL '1 day'