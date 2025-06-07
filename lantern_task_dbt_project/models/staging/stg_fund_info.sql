with fund_info as (select * from {{ source('transactions', 'fund_info') }})

select
  company_id,
  company,
  fund,
  invested as amount_invested,
  invested_date
from fund_info