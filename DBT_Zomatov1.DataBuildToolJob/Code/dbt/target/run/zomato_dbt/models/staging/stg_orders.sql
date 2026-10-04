USE [WH_Zomato];
    
    

    EXEC('create view [staging].[stg_orders] as select
    trim(order_id) as order_id,

    try_cast(order_timestamp as datetime2) as order_timestamp,

    try_cast(order_date as date) as order_date,

    trim(user_id) as user_id,
    trim(r_id) as restaurant_id,
    trim(restaurant_city) as restaurant_city,
    trim(cuisine) as cuisine,

    try_cast(items_count as int) as items_count,
    try_cast(sales_qty as int) as sales_qty,

    try_cast(subtotal as decimal(12,2)) as subtotal,
    try_cast(discount as decimal(12,2)) as discount,
    try_cast(delivery_fee as decimal(12,2)) as delivery_fee,
    try_cast(gst as decimal(12,2)) as gst,
    try_cast(sales_amount as decimal(12,2)) as sales_amount,

    trim(currency) as currency,
    trim(payment_method) as payment_method,
    trim(order_status) as order_status,

    try_cast(customer_rating as decimal(3,1)) as customer_rating,
    try_cast(delivery_time_min as int) as delivery_time_min

from [LH_Zomato_Bronze].[dbo].[orders_raw];');


