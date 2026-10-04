# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "9b24ad13-d48e-42e4-a3af-923d6bf3f4f4",
# META       "default_lakehouse_name": "LH_Zomato_Bronze",
# META       "default_lakehouse_workspace_id": "1b578a91-56d8-4afd-a1fe-ef5156c0cdbf",
# META       "known_lakehouses": [
# META         {
# META           "id": "9b24ad13-d48e-42e4-a3af-923d6bf3f4f4"
# META         }
# META       ]
# META     },
# META     "warehouse": {
# META       "known_warehouses": []
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql import functions as F

tables = {
    "orders_raw": ["order_id"],
    "order_items_raw": ["order_item_id"],
    "reviews_raw": ["review_id"],
    "users_raw": ["user_id"],
    "restaurants_raw": ["id"],
    "food_raw": ["f_id"],
    "menu_raw": ["menu_id"],
}

for table_name, keys in tables.items():
    df = spark.table(table_name)

    if df.count() == 0:
        raise ValueError(f"{table_name}: table rong")

    for key in keys:
        null_count = df.filter(F.col(key).isNull()).count()
        if null_count > 0:
            raise ValueError(
                f"{table_name}: {key} co {null_count} NULL"
            )

print("Bronze DQ PASS")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
