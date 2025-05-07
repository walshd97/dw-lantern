{{ config(materialized='table', alias='01_company_report_cleaned') }}

with comp_stats as (
    select company_id, company, 
    quarter as quarter_start_date,
    month(quarter) as month,
    year(quarter) as year,
    case 
        when month in (1, 2, 3) then 'q1'
        when month in (4, 5, 6) then 'q2'
        when month in (7, 8, 9) then 'q3'
        when month in (10, 11, 12) then 'q4'
    end as quarter,
    sales_amount, buy_cost_amount, 
    total_revenue, total_cost,
    total_revenue - total_cost as total_profit
    from {{source ('transactions', 'company_report')}}
)
select 
    company_id, company, 
    concat(year, '_', quarter) as year_quarter,
    quarter, year, quarter_start_date,
    sales_amount, buy_cost_amount, 
    total_revenue, total_cost, 
    total_profit,
from comp_stats

