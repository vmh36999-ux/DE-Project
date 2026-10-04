
        
  
        
            
            
            
            
        
    

    

    merge into [WH_Zomato].[staging].[fct_orders] as DBT_INTERNAL_DEST
        using [WH_Zomato].[staging].[fct_orders__dbt_tmp] as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.order_id = DBT_INTERNAL_DEST.order_id))

    
    when matched then update set
        [order_id] = DBT_INTERNAL_SOURCE.[order_id],[customer_id] = DBT_INTERNAL_SOURCE.[customer_id],[restaurant_id] = DBT_INTERNAL_SOURCE.[restaurant_id],[order_date] = DBT_INTERNAL_SOURCE.[order_date],[order_timestamp] = DBT_INTERNAL_SOURCE.[order_timestamp],[items_count] = DBT_INTERNAL_SOURCE.[items_count],[sales_qty] = DBT_INTERNAL_SOURCE.[sales_qty],[subtotal] = DBT_INTERNAL_SOURCE.[subtotal],[discount] = DBT_INTERNAL_SOURCE.[discount],[delivery_fee] = DBT_INTERNAL_SOURCE.[delivery_fee],[gst] = DBT_INTERNAL_SOURCE.[gst],[sales_amount] = DBT_INTERNAL_SOURCE.[sales_amount],[currency] = DBT_INTERNAL_SOURCE.[currency],[payment_method] = DBT_INTERNAL_SOURCE.[payment_method],[order_status] = DBT_INTERNAL_SOURCE.[order_status],[customer_rating] = DBT_INTERNAL_SOURCE.[customer_rating],[delivery_time_min] = DBT_INTERNAL_SOURCE.[delivery_time_min]
    

    when not matched then insert
        ([order_id], [customer_id], [restaurant_id], [order_date], [order_timestamp], [items_count], [sales_qty], [subtotal], [discount], [delivery_fee], [gst], [sales_amount], [currency], [payment_method], [order_status], [customer_rating], [delivery_time_min])
    values
        ([order_id], [customer_id], [restaurant_id], [order_date], [order_timestamp], [items_count], [sales_qty], [subtotal], [discount], [delivery_fee], [gst], [sales_amount], [currency], [payment_method], [order_status], [customer_rating], [delivery_time_min])

;

        
    

