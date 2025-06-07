with new_transactions as (select * from {{ source('transactions', 'new_transactions') }})

select
  company,
  date,
  case when "Transaction Type" in ('Sales of Item  ', 'Sales of Items') then 'Sales of Item' else "Transaction Type" end as transaction_type,
  amount,
  number
from new_transactions
