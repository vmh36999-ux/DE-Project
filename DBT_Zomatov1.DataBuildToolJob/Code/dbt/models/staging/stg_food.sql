select
    trim(f_id) as food_id,
    trim(item) as food_name,
    trim(veg_or_non_veg) as food_type

from {{ source('bronze', 'food_raw') }}