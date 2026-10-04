USE [WH_Zomato];
    
    

    EXEC('create view [staging].[stg_reviews] as select
    trim(review_id) as review_id,
    trim(order_id) as order_id,
    trim(user_id) as user_id,
    trim(restaurant_id) as restaurant_id,

    try_cast(rating as decimal(3,1)) as rating,

    trim(comment) as comment,

    try_cast(review_date as date) as review_date

from [LH_Zomato_Bronze].[dbo].[reviews_raw];');


