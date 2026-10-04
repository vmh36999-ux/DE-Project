
    
    with test_main_sql as (
  
    
    
    

select
    order_item_id as unique_field,
    count(*) as n_records

from [WH_Zomato].[staging].[stg_order_items]
where order_item_id is not null
group by order_item_id
having count(*) > 1



  
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