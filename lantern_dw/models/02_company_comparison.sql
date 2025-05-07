{{ config(materialized='table', alias='02_company_comparison') }}

with comp_comparison as (
    select company_id, company, left(year_quarter, 4) as year, 
        sum(actual_total_profit) as total_yearly_profit,
        sum(actual_total_cost) as total_yearly_cost,
        sum(actual_total_revenue) as total_yearly_revenue
        from {{ ref ('02_company_performance_validation') }}
        group by company_id, company, year
        
),

trans_filter as (
    select 
        company,
        year(date) as year,
        transaction_type
    from {{source ('transactions', 'transactions') }}
    where transaction_type = 'Sales of Item'
),

num_trans as (
    select 
        company, 
        year,
        count(1) as num_transactions
    from trans_filter
    group by company, year
)

select
    c.company_id, c.company, c.year, 
    c.total_yearly_revenue, c.total_yearly_cost, 
    c.total_yearly_profit, t.num_transactions,
from comp_comparison as c
left join num_trans as t
on c.company = t.company and c.year = t.year
order by total_yearly_profit desc
