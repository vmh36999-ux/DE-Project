USE [WH_Zomato];
    
    

    EXEC('create view [staging].[stg_menu] as select
    trim(menu_id) as menu_id,
    trim(r_id) as restaurant_id,
    trim(f_id) as food_id,
    trim(cuisine) as cuisine,

    try_cast(
        replace(replace(trim(price), ''₹'', ''''), '','', '''')
        as decimal(10,2)
    ) as price

from [LH_Zomato_Bronze].[dbo].[menu_raw];');


