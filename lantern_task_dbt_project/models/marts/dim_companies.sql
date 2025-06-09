with stg_company_report as (select * from {{ ref("stg_company_report") }})

select distinct
company_id,
case when company = 'TitanTech' then 'The Titan Tech' else company end as company
from stg_company_report