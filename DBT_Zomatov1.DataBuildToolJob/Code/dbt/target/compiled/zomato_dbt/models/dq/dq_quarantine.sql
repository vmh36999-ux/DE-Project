

with invalid_records as (

    -- 1. Order bị thiếu order_id
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942' as run_id,
        'stg_orders' as table_name,
        cast(order_id as varchar(100)) as record_key,
        'null_check' as error_type,
        'order_id bi NULL' as error_message,
        cast(getdate() as datetime2(6)) as detected_at
    from [WH_Zomato].[staging].[stg_orders]
    where order_id is null


    union all


    -- 2. Sales amount không hợp lệ
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942',
        'stg_orders',
        cast(order_id as varchar(100)),
        'business_rule',
        'sales_amount <= 0',
        cast(getdate() as datetime2(6))
    from [WH_Zomato].[staging].[stg_orders]
    where sales_amount <= 0


    union all


    -- 3. Order date nằm ở tương lai
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942',
        'stg_orders',
        cast(order_id as varchar(100)),
        'business_rule',
        'order_date > current_date',
        cast(getdate() as datetime2(6))
    from [WH_Zomato].[staging].[stg_orders]
    where order_date > cast(getdate() as date)


    union all


    -- 4. order_items trỏ tới order không tồn tại
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942',
        'stg_order_items',
        cast(oi.order_item_id as varchar(100)),
        'referential_integrity',
        'order_id khong ton tai trong stg_orders',
        cast(getdate() as datetime2(6))
    from [WH_Zomato].[staging].[stg_order_items] oi
    left join [WH_Zomato].[staging].[stg_orders] o
        on oi.order_id = o.order_id
    where o.order_id is null


    union all


    -- 5. Quantity phải > 0
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942',
        'stg_order_items',
        cast(order_item_id as varchar(100)),
        'business_rule',
        'quantity phai lon hon 0',
        cast(getdate() as datetime2(6))
    from [WH_Zomato].[staging].[stg_order_items]
    where quantity <= 0


    union all


    -- 6. Rating phải nằm trong 1-5
    select
        '87dd5745-af5e-4962-953b-ec42b1ea2942',
        'stg_reviews',
        cast(review_id as varchar(100)),
        'range_validation',
        'rating phai nam trong khoang 1 den 5',
        cast(getdate() as datetime2(6))
    from [WH_Zomato].[staging].[stg_reviews]
    where rating < 1
       or rating > 5
)

select
    concat(
        run_id, '|',
        table_name, '|',
        coalesce(record_key, 'NULL'), '|',
        error_type
    ) as quarantine_id,
    run_id,
    table_name,
    record_key,
    error_type,
    error_message,
    detected_at

from invalid_records