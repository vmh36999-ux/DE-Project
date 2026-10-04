select
    order_date,
    restaurant_city as city,

    count(distinct order_id) as total_orders,

    sum(sales_amount) as total_revenue,

    avg(sales_amount) as average_order_value

from {{ ref('stg_orders') }}

group by
    order_date,
    restaurant_city