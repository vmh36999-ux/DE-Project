{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

select
    order_id,
    user_id as customer_id,
    restaurant_id,
    order_date,
    try_cast(order_timestamp as datetime2(6)) as order_timestamp,
    items_count,
    sales_qty,
    subtotal,
    discount,
    delivery_fee,
    gst,
    sales_amount,
    currency,
    payment_method,
    order_status,
    customer_rating,
    delivery_time_min

from {{ ref('stg_orders') }}

{% if is_incremental() %}

where order_date > (
    select max(order_date)
    from {{ this }}
)

{% endif %}