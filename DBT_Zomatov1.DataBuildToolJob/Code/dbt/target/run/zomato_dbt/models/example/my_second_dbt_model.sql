USE [WH_Zomato];
    
    

    EXEC('create view [staging].[my_second_dbt_model] as -- Use the `ref` function to select from other models

select *
from [WH_Zomato].[staging].[my_first_dbt_model]
where id = 1;');


