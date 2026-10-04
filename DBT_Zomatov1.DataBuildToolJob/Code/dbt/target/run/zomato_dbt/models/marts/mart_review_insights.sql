
  
    
    

    

        CREATE TABLE [WH_Zomato].[staging].[mart_review_insights__dbt_tmp]
        
        AS select
    restaurant_id,

    count(*) as total_reviews,

    avg(rating) as average_rating,

    sum(
        case
            when rating >= 4 then 1
            else 0
        end
    ) as positive_reviews,

    sum(
        case
            when rating <= 2 then 1
            else 0
        end
    ) as negative_reviews,

    max(review_date) as latest_review_date

from [WH_Zomato].[staging].[stg_reviews]

group by
    restaurant_id

    

  
  