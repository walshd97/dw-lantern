{{ config(materialized='table', alias='02_correct_company_report') }}

select 
    company_id, company, 
    case 
        when year_quarter like '%q1' then cast(substring(year_quarter, 1, 4) || '-01-01' as date)
        when year_quarter like '%q2' then cast(substring(year_quarter, 1, 4) || '-04-01' as date)
        when year_quarter like '%q3' then cast(substring(year_quarter, 1, 4) || '-07-01' as date)
        when year_quarter like '%q4' then cast(substring(year_quarter, 1, 4) || '-10-01' as date)
    end as quarter_start_date,
    actual_sales_amount as sales_amount,
    actual_buy_cost_amount as buy_cost_amount,
    actual_total_cost as total_cost,
    actual_total_revenue as total_revenue,
from {{ref ('02_company_performance_validation')}}
order by company_id, quarter_start_date

    