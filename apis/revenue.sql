select measure(total_revenue) as total_revenue ,
date_trunc({{context.params.time_period | is_required | is_enum(items=['week', 'month', 'year','day','hour'])}},invoice_date) as time_period 
from sales group by 2 ;


