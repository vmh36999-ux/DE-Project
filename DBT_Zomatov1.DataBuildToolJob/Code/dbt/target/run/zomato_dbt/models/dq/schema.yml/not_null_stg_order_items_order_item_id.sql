
    
    with test_main_sql as (
  
    
    
    



select order_item_id
from [WH_Zomato].[staging].[stg_order_items]
where order_item_id is null



  
  ),
  dbt_internal_test as (
    select  * from test_main_sql
  )
  select
    count(*) as failures,
    case when count(*) != 0
      then 'true' else 'false' end as should_warn,
    case when count(*) != 0
      then 'true' else 'false' end as should_error
  from dbt_internal_test