{{ config(materialized='table', alias='02_company_performance_validation') }}


with cte as (
    select 
        f.company_id, t.company, 
        t.date, 
        t.transaction_type, 
        t.amount, 
        t.number,
        month(t.date) as month,
        year(t.date) as year
    from {{ source('transactions', 'transactions') }} as t
    join {{ source('transactions', 'fund_info') }} as f
        on t.company = f.company
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
        sum(case when transaction_type = 'Sales of Item' then amount else 0 end) as sales_amount_trans,
        sum(case when transaction_type = 'Buy Item Cost' then amount else 0 end) as buy_cost_amount_trans,
        sum(case when transaction_type = 'Upkeep Cost' then amount else 0 end) as upkeep_cost_trans
    from quarters
    group by company_id, company, year_quarter
),
final_trans_report as (
    select 
        t.company_id, 
        t.company, 
        t.year_quarter,
        t.sales_amount_trans as actual_sales_amount,
        t.buy_cost_amount_trans as actual_buy_cost_amount,
        t.buy_cost_amount_trans + t.upkeep_cost_trans as actual_total_cost,

        t.sales_amount_trans as actual_total_revenue
    from trans_data as t
),

comp_report as (
    select 
        company_id, 
        company, 
        year_quarter,
        sum(total_revenue) as reported_total_revenue,
        sum(total_cost) as reported_total_cost,
        sum(total_profit) as reported_total_profit
    from {{ ref('01_company_report_cleaned') }}
    group by company_id, company, year_quarter
)

select 
    t.company_id, 
    t.company, 
    t.year_quarter, 
    t.actual_sales_amount,
    t.actual_buy_cost_amount,
    t.actual_total_cost, 
    r.reported_total_cost, 
    t.actual_total_revenue, 
    r.reported_total_revenue,
    t.actual_total_revenue - t.actual_total_cost as actual_total_profit,
    r.reported_total_profit,
    case 
        when actual_total_profit = r.reported_total_profit then 'Match'
        when actual_total_profit > r.reported_total_profit then 'Under Reported'
        when actual_total_profit < r.reported_total_profit then 'Over Reported'
    end as profit_report_status,
    from final_trans_report as t
    join comp_report as r
    on t.company_id = r.company_id and t.company = r.company and t.year_quarter = r.year_quarter