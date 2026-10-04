
  
    
    

    

        CREATE TABLE [WH_Zomato].[staging].[dim_food__dbt_tmp]
        
        AS select
    food_id,
    food_name,
    food_type

from [WH_Zomato].[staging].[stg_food]

    

  
  