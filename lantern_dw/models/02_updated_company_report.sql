-- Using new_transactions table with renamed company

{{ config(materialized='table', alias='02_updated_company_report') }}


with cte as (
    select 
        f.company_id, t.company_cleaned as company, 
        t.date, 
        t.transaction_type, 
        t.amount, 
        t.number,
        month(t.date) as month,
        year(t.date) as year
    from {{ ref('01_cleaned_transactions') }} as t
    join {{ ref('01_cleaned_fund_info') }} as f
        on t.company_cleaned = f.company_cleaned
),
agged_date as (
    select *,
        case 
            when month in (1, 2, 3) then 'q1'
            when month in (4, 5, 6) then 'q2'
            when month in (7, 8, 9) then 'q3'
            when month in (10, 11, 12) then 'q4'
        end as quarter
    from cte
),
quarters as (
    select *, 
        concat(year, '_', quarter) as year_quarter
    from agged_date
),
trans_data as (
    select 
        company_id, 
        company, 
        year_quarter, 
        sum(case when transaction_type = 'Sales of Item' then amount else 0 end) as sales_amount,
        sum(case when transaction_type = 'Buy Item Cost' then amount else 0 end) as buy_cost_amount,
        sum(case when transaction_type = 'Upkeep Cost' then amount else 0 end) as upkeep_cost
    from quarters
    group by company_id, company, year_quarter
)

select  
    company_id, 
    company, 
    case 
        when year_quarter like '%q1' then cast(substring(year_quarter, 1, 4) || '-01-01' as date)
        when year_quarter like '%q2' then cast(substring(year_quarter, 1, 4) || '-04-01' as date)
        when year_quarter like '%q3' then cast(substring(year_quarter, 1, 4) || '-07-01' as date)
        when year_quarter like '%q4' then cast(substring(year_quarter, 1, 4) || '-10-01' as date)
    end as quarter_start_date,
    sales_amount,
    buy_cost_amount,
    buy_cost_amount + upkeep_cost as total_cost,
    sales_amount as total_revenue
from trans_data