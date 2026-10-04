
  
    
    

    

        CREATE TABLE [WH_Zomato].[staging].[mart_daily_city_revenue__dbt_tmp]
        
        AS select
    order_date,
    restaurant_city as city,

    count(distinct order_id) as total_orders,

    sum(sales_amount) as total_revenue,

    avg(sales_amount) as average_order_value

from [WH_Zomato].[staging].[stg_orders]

group by
    order_date,
    restaurant_city

    

  
  