
  
    
    

    

        CREATE TABLE [WH_Zomato].[staging].[mart_restaurant_performance__dbt_tmp]
        
        AS select
    o.restaurant_id,
    r.restaurant_name,
    r.city,

    count(distinct o.order_id) as total_orders,

    sum(o.sales_amount) as total_revenue,

    avg(o.sales_amount) as average_order_value,

    avg(o.customer_rating) as average_customer_rating,

    avg(o.delivery_time_min) as average_delivery_time_min,

    sum(
        iif(o.order_status = 'Delivered', 1, 0)
    ) as delivered_orders

from [WH_Zomato].[staging].[stg_orders] o

left join [WH_Zomato].[staging].[stg_restaurants] r
    on o.restaurant_id = r.restaurant_id

group by
    o.restaurant_id,
    r.restaurant_name,
    r.city

    

  
  