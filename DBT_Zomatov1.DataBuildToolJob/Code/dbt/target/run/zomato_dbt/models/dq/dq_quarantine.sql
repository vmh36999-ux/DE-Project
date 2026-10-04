
        
  
        
            
            
            
            
        
    

    

    merge into [WH_Zomato].[staging].[dq_quarantine] as DBT_INTERNAL_DEST
        using [WH_Zomato].[staging].[dq_quarantine__dbt_tmp] as DBT_INTERNAL_SOURCE
        on ((DBT_INTERNAL_SOURCE.quarantine_id = DBT_INTERNAL_DEST.quarantine_id))

    
    when matched then update set
        [quarantine_id] = DBT_INTERNAL_SOURCE.[quarantine_id],[run_id] = DBT_INTERNAL_SOURCE.[run_id],[table_name] = DBT_INTERNAL_SOURCE.[table_name],[record_key] = DBT_INTERNAL_SOURCE.[record_key],[error_type] = DBT_INTERNAL_SOURCE.[error_type],[error_message] = DBT_INTERNAL_SOURCE.[error_message],[detected_at] = DBT_INTERNAL_SOURCE.[detected_at]
    

    when not matched then insert
        ([quarantine_id], [run_id], [table_name], [record_key], [error_type], [error_message], [detected_at])
    values
        ([quarantine_id], [run_id], [table_name], [record_key], [error_type], [error_message], [detected_at])

;

        
    

