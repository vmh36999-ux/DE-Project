
  
    
    

    

        CREATE TABLE [WH_Zomato].[staging].[dim_restaurant__dbt_tmp]
        
        AS select
    restaurant_id,
    restaurant_name,
    city,
    rating,
    cost_for_two,
    cuisine,
    license_no,
    link,
    address

from [WH_Zomato].[staging].[stg_restaurants]

    

  
  