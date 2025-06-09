with company_report_v2 as (select * from {{ ref("company_report_v2") }})

select 
company,
sum(sales_amount_v2) as total_sales,
sum(gross_profit) as gross_profit,
avg(change_in_sales_from_prev_qtr) as avg_sales_growth_per_qtr,
avg(percent_change_in_sales_from_prev_qtr) as avg_perc_sales_growth_per_qtr
from company_report_v2
where quarter <> '2025-01-01' --Exclude Q1 2025 as it is an incomplete quarter (only data for Jan)
group by 1
order by gross_profit desc