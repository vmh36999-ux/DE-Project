select
    id as restaurant_id,
    trim(name) as restaurant_name,
    trim(city) as city,
    case
        when trim(rating) in ('--', '') then null
        else try_cast(trim(rating) as decimal(3,1))
    end as rating,
    try_cast(
        replace(replace(trim(cost), '₹', ''),' ','') as decimal(10,2)
    ) as cost_for_two,
    trim(cuisine) as cuisine,
    trim(lic_no) as license_no,
    link,
    address,
    menu
from {{ source('bronze', 'restaurants_raw') }}