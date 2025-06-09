with stg_transactions as (select * from {{ ref("stg_transactions") }}),
stg_new_transactions as (select * from {{ ref("stg_new_transactions") }}),
stg_fund_info as (select * from {{ ref("stg_fund_info") }}),


transactions_combined as (
    select * from stg_transactions --This is 2024 data
    union
    select * from stg_new_transactions --This is 2025 data
)

--Below we need to update TitanTech to new name
select 
c.company_id,
case when tc.company = 'TitanTech' then 'The Titan Tech' else tc.company end as company,
fi.fund, --This will only be not null for dates from when the fund was invested in the company
tc.date,
tc.transaction_type,
tc.amount,
tc.number
from transactions_combined tc 
left join dim_companies c on case when tc.company = 'TitanTech' then 'The Titan Tech' else tc.company end = c.company -- join onto dim_companies to retrieve company_id
left join stg_fund_info fi on c.company_id = fi.company_id -- join fund info for use in the fund analysis
                          and tc.date >= fi.invested_date 
order by c.company_id, tc.date