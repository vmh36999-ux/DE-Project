-- Use the `ref` function to select from other models

select *
from [WH_Zomato].[staging].[my_first_dbt_model]
where id = 1