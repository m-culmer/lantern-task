/*
    - Which **fund** is performing the **best** overall?
    - Which fund has the **highest ROI**, based on Invested value and cash in bank?
    - What **additional metric(s)** would you propose to evaluate fund performance?

    > 💡 Bonus: Explain why your proposed metric(s) could be useful to stakeholders.

ROI = (invested_companies_gross_profit_since_investment / amount_invested_in_companies) * 100

Question 1: Which fund is performing the best overall?
Answer: Fund 2 is performing best overall in terms of absolute returns. They have invested a total of $160k into companies which have generated gross profit of $518k. Whereas Fund 1 invested $200k into companies that have generated only $212k. 

Question 2: Which fund has the highest ROI?
Answer: Fund 2 has the highest ROI at 323.7%, compared to 106.4% for Fund 1.

Question 3: What additional metrics would you propose to evaluate fund performance? And why are they useful to stakeholders?
Answer: 
1. Annualised ROI. This calcuates ROI, but considers how long the investent has been held for. See fund_performance_company_level CTE for full calculation. 
Why is this useful to stakeholders? It demonstrates efficiency in generating returns. A 2x return over 3 years (26% annualised) is much better than over 10 years (7% annualised)
A limitation with annualised ROI is that while it is useful to evaluate investment performance within a fund, it is not typically used as a comparison across funds. 
In this dataset it is still useful to compare as you can see that Fund 1 has annualised ROIs of 0.6% and 1.35% whereas Fund 2 has 17%, 10% and 4% - A clear winner in terms of returns performance. 


2. MOIC (Multiple on Invested Capital). This is The total value generated per dollar invested.
Why is this useful to stakeholders? Simple and easy to digest way to compare fund performance. For example Fund 1 has an MOIC of 2.06, this means For every dollar the fund invested, it has returned $2.06 in total value (including the original capital). This is less than Fund 2 which has an MOIC 4.24.

*/
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
    power((amount_invested + gross_profit) / amount_invested, 1.0 / years_invested) - 1 as annualized_roi,
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