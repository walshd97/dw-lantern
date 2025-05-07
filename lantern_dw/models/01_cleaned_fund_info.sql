{{ config(materialized='table', alias='01_cleaned_fund_info') }}

select 
    company_id,
    case when company = 'TitanTech' then 'The Titan Tech' 
    else company
    end as company_cleaned,
    fund, invested
from {{source ('transactions', 'fund_info') }}
