-- select sales.total_revenue, account.city from sales left join account on sales.__joinField = account.__joinField
select measure(total_revenue) as total_revenue , account.city from sales left join account on sales.__joinField = account.__joinField group by 2;