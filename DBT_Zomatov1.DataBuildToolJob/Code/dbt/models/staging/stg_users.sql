select
    trim(user_id) as user_id,
    trim(name) as user_name,
    trim(email) as email,
    trim(password) as password,
    try_cast(nullif(trim(Age), '') as int) as age,
    trim(Gender) as gender,
    trim(Marital_Status) as marital_status,
    trim(Occupation) as occupation,
    try_cast(
        replace(replace(trim(Monthly_Income), ',', ''), '₹', '')
        as decimal(12,2)
    ) as monthly_income,
    trim(Educational_Qualifications) as educational_qualifications,
    try_cast(
        trim(Family_size) as int
    ) as family_size
from {{ source('bronze','users_raw')}}