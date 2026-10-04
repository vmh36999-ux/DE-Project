select
    restaurant_id,
    restaurant_name,
    city,
    rating,
    cost_for_two,
    cuisine,
    license_no,
    link,
    address

from {{ ref('stg_restaurants') }}