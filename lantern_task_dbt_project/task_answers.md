## Part 1 - Create environment and dbt project:

**1. Create dbt project and establish connection.** - Steps taken:
  - Installed VScode (and relevant extensions e.g. dbt Power User)
  - Installed Python & pip
  - Installed Git
  - Installed dbt with duckdb adapter: `pip install dbt-duckdb`
  - Cloned the repo: `git clone https://github.com/m-culmer/lantern-task.git`
  - Opened the repo: `cd lantern-task`
  - Created dbt project: `dbt init lantern_task_dbt_project`
  - Chose duckdb adapter
  - setup `profiles.yml`
  - Add relevant dbt packages (just dbt_utils in this case)

**2. Create connection to database:** - Steps taken:
  - Added the database file to the dbt project directory
  - Setup `profiles.yml` with relevant connection details
  - Created `sources.yml` file to connect to the duckdb tables
  - Created staging models and test connections

## Part 2 - Data Validation & Insight Generation

**Question 1:** Are companies misreporting data

**Answer:** 
 
 Yes. Company 'Omnicorp' (company_id = 4) has over-inflated their sales amount by $10k per quarter in 2024. 
 In total Omnicorp over inflated their sales by +5% in 2024, reporting $767,300 instead of the actual sales of $727,300.  
 Relevant models: 
 ``` 
 models\final_analysis\analysis_p2a_misreporting.sql 
 models\marts\company_report_v2.sql 
 ```



**Question 2 & 3:** Which company is performing the best and the worst? Which company shows the most growth over time?

**Answer:**   

Note: Excluded Q1 2025 (i.e. new_transactions) as it is an incomplete quarter (only data for Jan) and we are analysing on a per-qtr basis.

Performance metrics considered:
1. 2024 Sales Amount (sum of sales in 2024)
2. 2024 Gross Profit (sum of sales in 2024 minus sum of costs in 2024)
3. Avg sales growth per qtr in 2024

Justification: One company may have higher sales, but if their costs are much higher relative to sales then their profit is lower. 
We will look at 2024 as a whole to analyse performance, but also consider growth as this could indicate future performance. 

**Part 1 (performance) Answer:**

Best performing company = Nanobuild. Although not the highest sales ($580k vs $837k for The Titan Tech), they have the highest gross profit at $227k and the highest growth with an average growth in sales of 54% per qtr in 2024, indicating they are likely to continue performing well in the future too.  
  
Worst performing company = Modugear. They have the lowest sales, lowest gross profit and are the only company to have declining growth throughout 2024.


**Part 2 (growth) Answer:**

Nanobuild is showing the most growth at an average increase in sales of 54% or $49.5k per qtr in 2024.
Freshbyte is also showing good growth at average increase in sales of 44% or $43k per qtr.

Titantech and Omnicorp are showing mediocre growth at 1-3% per qtr on average. 

The worst company for growth is Modugear at -30% (-$34.5k) decrease in sales amount per qtr on average for 2024. 

Relevant models: 
``` 
models\intermediary\int_transactions_combined.sql 
models\final_analysis\analysis_p2b_performance_and_growth.sql 
models\marts\company_report_v2.sql 
```

## Part 3 - Data Update Task

**Task:** Update models to reflect updated company name: `TitanTech` to `The Titan Tech`.

**All models have been updated to reflect the changes.** See relevant models below for the top level tables where the updates were made:
``` 
models\intermediary\int_transactions_combined.sql 
models\marts\dim_companies.sql 
```

## Part 4 - Fund Analysis

**Question 1:** Which fund is performing the best overall?

**Answer:** 

Fund 2 is performing best overall in terms of absolute returns. They have invested a total of $160k into companies which have generated gross profit of $518k since the investment dates. Whereas Fund 1 invested $200k into companies that have generated only $212k since investment. 

**Question 2:** Which fund has the highest ROI?

**Answer:** 

Fund 2 has the highest ROI at 323.7%, compared to 106.4% for Fund 1.
Calculation:  
```round((total_invested_company_gross_profit / total_amount_invested) * 100, 2) as overall_roi_percent```

**Question 3:** What additional metrics would you propose to evaluate fund performance? Why are they useful to stakeholders?

**Answer:** 

1. **Annualised ROI.** This calcuates ROI, but considers how long the investent has been held for. See fund_performance_company_level CTE for full calculation.     
**Why is this useful to stakeholders?** - It demonstrates efficiency in generating returns. A 2x return over 3 years (26% annualised) is much better than over 10 years (7% annualised).
A limitation with annualised ROI is that while it is useful to evaluate investment performance within a fund, it is not typically used as a comparison across funds.
In this dataset it is still useful to compare as you can see that Fund 1 has annualised ROIs of 0.6% and 1.35% whereas Fund 2 has 17%, 10% and 4% - A clear winner in terms of returns performance. 

2. **MOIC (Multiple on Invested Capital).** This is The total value generated per dollar invested.  
**Why is this useful to stakeholders?** - It is a simple and easy to digest metric to compare fund performance. For example Fund 1 has an MOIC of 2.06, this means For every dollar the fund invested, it has returned $2.06 in total value (including the original capital). This is less than Fund 2 which has an MOIC 4.24.

                Relevant models: 
                ``` 
                models\final_analysis\analysis_p4_fund_performance.sql 
                models\intermediary\int_transactions_combined.sql 
                ```
