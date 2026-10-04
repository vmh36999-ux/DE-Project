with all_dates as (

    select order_date as date_day
    from [WH_Zomato].[staging].[stg_orders]
    where order_date is not null

    union

    select review_date as date_day
    from [WH_Zomato].[staging].[stg_reviews]
    where review_date is not null
)

select
    date_day,
    year(date_day) as year,
    month(date_day) as month,
    day(date_day) as day,
    datepart(quarter, date_day) as quarter,
    datepart(weekday, date_day) as day_of_week

from all_dates