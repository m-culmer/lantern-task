with company_report as (select * from {{ source('transactions', 'company_report') }})

select
  company_id,
  company,
  quarter,
  sales_amount,
  buy_cost_amount,
  total_cost,
  total_revenue
from company_report