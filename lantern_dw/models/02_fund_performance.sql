{{ config(materialized='table', alias='02_fund_performance') }}

with company_cash as (
    select 
        company_cleaned as company,
        sum(case when transaction_type = 'Sales of Item' then amount else 0 end) as inflow,
        sum(case when transaction_type in ('Buy Item Cost', 'Upkeep Cost') then amount else 0 end) as outflow
    from {{ref ('01_cleaned_transactions') }}
    group by company
),

overall_fund as (
    select 
        fund, sum(invested) as total_invested
    from {{ ref ('01_cleaned_fund_info') }}
    group by fund
),

fund_performance_1 as (
    select  
        f.fund, 
        sum(f.invested) as invested,
        sum(c.inflow) as inflow,
        sum(c.outflow) as outflow,
    from {{ ref ('01_cleaned_fund_info') }} as f
    join company_cash as c
    on f.company_cleaned = c.company
    group by fund
)

select
        fund, invested, 
        inflow, outflow, 
        invested + inflow - outflow as final_balance
from fund_performance_1


