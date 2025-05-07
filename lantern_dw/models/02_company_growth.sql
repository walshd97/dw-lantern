{{ config(materialized='table', alias='02_company_growth') }}
-- Growth per quarter

with ordered_table as (
    select *,
    total_revenue - total_cost as total_profit
    from {{ ref('02_correct_company_report') }}
    order by company_id, quarter_start_date
),
-- Get previous quarter sales amount
lag_results as (
    select 
        company_id, 
        company, 
        quarter_start_date,
        sales_amount, 
        total_profit,
        lag(sales_amount) over (partition by company_id order by quarter_start_date) as prev_sales,
        lag(total_profit) over (partition by company_id order by quarter_start_date) as prev_profit
    from ordered_table
) 
select 
    company_id,
    company, 
    quarter_start_date,
    sales_amount,
    case 
        when prev_sales is null then null
        else round((sales_amount - prev_sales) / prev_sales * 100, 2)
    end as sales_growth,
    total_profit,
    case 
        when prev_profit is null then null
        else round((total_profit - prev_profit) / prev_sales * 100, 2)
    end as profit_growth,
from lag_results
order by company_id, quarter_start_date