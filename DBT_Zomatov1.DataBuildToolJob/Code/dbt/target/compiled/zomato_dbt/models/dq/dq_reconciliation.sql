

with bronze_check as (

    select
        count(*) as bronze_rows,
        count(distinct order_id) as bronze_distinct_orders

    from LH_Zomato_Bronze.dbo.orders_raw

    where order_id is not null
),

mart_check as (

    select
        count(*) as mart_rows,
        count(distinct order_id) as mart_distinct_orders

    from [WH_Zomato].[staging].[fct_orders]
)

select
    cast(getdate() as datetime2(6)) as checked_at,

    bronze_rows,
    mart_rows,

    bronze_distinct_orders,
    mart_distinct_orders,

    bronze_distinct_orders - mart_distinct_orders as row_difference,

    case
        when bronze_distinct_orders = mart_distinct_orders
        then 'PASS'
        else 'FAIL'
    end as reconciliation_status

from bronze_check
cross join mart_check