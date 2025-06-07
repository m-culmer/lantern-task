with transactions as (select * from {{ source('transactions', 'transactions') }})

select
  company,
  date,
  transaction_type,
  amount,
  number
from transactions