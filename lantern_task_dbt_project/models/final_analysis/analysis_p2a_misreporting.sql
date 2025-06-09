with stg_company_report as (select * from {{ ref("stg_company_report") }}),
company_report_v2 as (select * from {{ ref("company_report_v2") }})

select cr1.company_id,
       cr1.company,
       cr1.quarter,

       cr1.sales_amount,
       cr2.sales_amount_v2,
       cr2.sales_amount_v2 - cr1.sales_amount as sales_amount_delta,

       cr1.buy_cost_amount,
       cr2.buy_cost_amount_v2,
       cr2.buy_cost_amount_v2 - cr1.buy_cost_amount as buy_cost_delta,

       cr1.total_cost,
       cr2.total_cost_v2,
       cr2.total_cost_v2 - cr1.total_cost as total_cost_delta

 from stg_company_report cr1
left join company_report_v2 cr2 on cr1.company = cr2.company
                               and cr2.quarter = cr1.quarter
order by 1, 3