USE [WH_Zomato];
    
    

    EXEC('create view [staging].[stg_food] as select
    trim(f_id) as food_id,
    trim(item) as food_name,
    trim(veg_or_non_veg) as food_type

from [LH_Zomato_Bronze].[dbo].[food_raw];');


