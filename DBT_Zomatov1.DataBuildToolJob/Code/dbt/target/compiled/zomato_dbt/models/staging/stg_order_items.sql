select
    trim(order_item_id) as order_item_id,
    trim(order_id) as order_id,
    trim(r_id) as restaurant_id,
    trim(f_id) as food_id,

    try_cast(price as decimal(10,2)) as price,
    try_cast(quantity as int) as quantity,
    try_cast(line_amount as decimal(12,2)) as line_amount

from [LH_Zomato_Bronze].[dbo].[order_items_raw]