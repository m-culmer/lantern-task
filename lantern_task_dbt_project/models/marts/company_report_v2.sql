with int_transactions_combined as (select * from {{ ref("int_transactions_combined") }})

select
company,
date_trunc('quarter', date) as quarter,
-- name below metrics V2 as original company_report is V1. 
sum(case when transaction_type = 'Sales of Item' then amount else 0 end) as sales_amount_v2,
sum(case when transaction_type = 'Buy Item Cost' then amount else 0 end) as buy_cost_amount_v2,
sum(case when transaction_type = 'Upkeep Cost' then amount else 0 end) as upkeep_cost_amount_v2,
sum(case when transaction_type <> 'Sales of Item' then amount else 0 end) as total_cost_v2,
-- revenue comparison not needed as this is equal to sales_amount

-- now calculate growth and performance metrics: 
sales_amount_v2 - total_cost_v2 as gross_profit,
lag(sales_amount_v2) over (partition by company order by quarter) as prev_sales_amount,
sales_amount_v2 - prev_sales_amount as change_in_sales_from_prev_qtr,
round(((sales_amount_v2 / prev_sales_amount) - 1) * 100, 1) as percent_change_in_sales_from_prev_qtr
from int_transactions_combined
group by 1, 2
order by 1, 2