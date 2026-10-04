{{ config(
    materialized='incremental',
    unique_key='order_item_id',
    incremental_strategy='merge'
) }}

select
    order_item_id,
    order_id,
    restaurant_id,
    food_id,
    price,
    quantity,
    line_amount

from {{ ref('stg_order_items') }}

{% if is_incremental() %}

where order_item_id not in (
    select order_item_id
    from {{ this }}
)

{% endif %}