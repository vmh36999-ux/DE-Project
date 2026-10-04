
        
  
        
            
            
            
            
        
    

    

    merge into [WH_Zomato].[staging].[fact_order_items] as DBT_INTERNAL_DEST
        using [WH_Zomato].[staging].[fact_order_items__dbt_tmp] as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.order_item_id = DBT_INTERNAL_DEST.order_item_id))

    
    when matched then update set
        [order_item_id] = DBT_INTERNAL_SOURCE.[order_item_id],[order_id] = DBT_INTERNAL_SOURCE.[order_id],[restaurant_id] = DBT_INTERNAL_SOURCE.[restaurant_id],[food_id] = DBT_INTERNAL_SOURCE.[food_id],[price] = DBT_INTERNAL_SOURCE.[price],[quantity] = DBT_INTERNAL_SOURCE.[quantity],[line_amount] = DBT_INTERNAL_SOURCE.[line_amount]
    

    when not matched then insert
        ([order_item_id], [order_id], [restaurant_id], [food_id], [price], [quantity], [line_amount])
    values
        ([order_item_id], [order_id], [restaurant_id], [food_id], [price], [quantity], [line_amount])

;

        
    

