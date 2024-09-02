{% set query_result = {
    "total_revenue_last_invoice_date": 20136,
    "percentage_change": null,
    "trend_last_7_days": [117816, 43284, 53514, 75294, 85902, 7692, 20136]
} %}
{% set var =  {
        "headers": { "Authorization" : "Bearer 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" },
        "body" : { "inputs" : query_result | string |list }
    } 
%}


SELECT {{ var |rest_api(url='https://api-inference.huggingface.co/models/facebook/bart-large-cnn', method = 'POST') }}