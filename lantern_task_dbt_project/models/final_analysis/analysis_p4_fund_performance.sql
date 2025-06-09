with stg_fund_info as (select * from {{ ref("stg_fund_info") }}),
int_transactions_combined as (select * from {{ ref("int_transactions_combined") }}),

fund_performance_company_level as (
    select 
    tc.fund,
    tc.company_id,
    tc.company,
    fi.amount_invested,
    fi.invested_date,
    datediff('day', fi.invested_date, '2025-01-31') / 365.25 as years_invested, --Used in annualised ROI calculation
    sum(case when tc.transaction_type = 'Sales of Item' then tc.amount else 0 end) as sales,
    sum(case when tc.transaction_type <> 'Sales of Item' then tc.amount else 0 end) as cost,
    sales - cost as gross_profit,
    round((gross_profit / amount_invested) * 100, 2) as fund_company_roi_percent,
    power((amount_invested + gross_profit) / amount_invested, 1.0 / years_invested) - 1 as annualised_roi,
    round((amount_invested + gross_profit) / amount_invested, 2) as moic 
    from int_transactions_combined tc
    inner join stg_fund_info fi on tc.company_id = fi.company_id -- using inner join to exclude pre-invested date
                               and tc.fund = fi.fund
    group by 1, 2, 3, 4, 5, 6
    order by 1, 2
)

select
fund,
sum(sales) as total_invested_company_sales,
sum(cost) as total_invested_company_cost,
sum(gross_profit) as total_invested_company_gross_profit,
sum(amount_invested) as total_amount_invested,
round((total_invested_company_gross_profit / total_amount_invested) * 100, 2) as overall_roi_percent,
round((total_amount_invested + total_invested_company_gross_profit) / total_amount_invested, 2) AS overall_moic 
from fund_performance_company_level
group by 1
