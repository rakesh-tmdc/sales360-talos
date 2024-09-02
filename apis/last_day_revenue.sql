 SELECT 
        measure(total_revenue) as revenue
        MAX(invoice_date) AS last_invoice_date
    FROM 
        sales