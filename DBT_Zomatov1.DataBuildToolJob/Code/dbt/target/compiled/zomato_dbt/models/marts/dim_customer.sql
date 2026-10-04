select
    user_id as customer_id,
    user_name as customer_name,
    email,
    age,
    gender,
    marital_status,
    occupation,
    monthly_income,
    educational_qualifications,
    family_size

from [WH_Zomato].[staging].[stg_users]