{{ config(materialized='table', alias='01_cleaned_transactions') }}

with renamed_columns as(
    select 
        TRIM(BOTH FROM Company) as company, 
        "date" as "date",
        case 
            when trim(both from "Transaction Type") in ('Sales of Item', 'Sales of Items' ) then 'Sales of Item'
        else "Transaction Type"
        end as transaction_type,
        amount as amount,
        cast(round(cast(Number as double), 0) as BIGINT) as number
    from {{ source('transactions', 'new_transactions') }}
),
unioned as (
    select * from renamed_columns
union 
select * from {{ source ('transactions', 'transactions')}}
)

select 
    case when company = 'TitanTech' then 'The Titan Tech' 
    else company
    end as company_cleaned,
    date, transaction_type, amount, number
from unioned

