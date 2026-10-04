

select
    order_item_id,
    order_id,
    restaurant_id,
    food_id,
    price,
    quantity,
    line_amount

from [WH_Zomato].[staging].[stg_order_items]



where order_item_id not in (
    select order_item_id
    from [WH_Zomato].[staging].[fact_order_items]
)

