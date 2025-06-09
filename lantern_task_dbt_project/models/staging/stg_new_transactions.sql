with new_transactions as (select * from {{ source('transactions', 'new_transactions') }})

select
  trim(company) as company, --Noticed a whitespace issue with FreshByte so adding a trim clause
  date,
  case when "Transaction Type" in ('Sales of Item  ', 'Sales of Items') then 'Sales of Item' else "Transaction Type" end as transaction_type,
  -- ^ I tried using trim() to remove the trailing whitespaces but this didn't work - So hardcoding the fix. Not future-proof but works for now. 
  amount,
  number
from new_transactions
