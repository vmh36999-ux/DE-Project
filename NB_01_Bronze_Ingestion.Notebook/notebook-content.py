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
from datetime import datetime
import uuid, hashlib, re

RUN_ID = str(uuid.uuid4())[:8] # Tạo ID riêng cho mỗi lần chạy Notebook

EXPECTED_SCHEMAS = {
    "food_raw":{"f_id","item","veg_or_non_veg"},
    "menu_raw":{"menu_id","r_id","f_id","cuisine","price"},
    "restaurants_raw":{"id","name","city","rating","rating_count","cost","cuisine","lic_no","link","address","menu"},
    "orders_raw": {"order_id","order_timestamp","order_date","user_id","r_id","restaurant_city","cuisine","items_count","sales_qty","subtotal","discount","delivery_fee","gst","sales_amount","currency","payment_method","order_status","customer_rating","delivery_time_min",},
    "order_items_raw": {"order_item_id","order_id","r_id","f_id","price","quantity","line_amount",},
    "reviews_raw": {"review_id","order_id","user_id","restaurant_id","rating","comment","review_date",},
    "users_raw": {"user_id","name","email","password","Age","Gender","Marital Status","Occupation","Monthly Income","Educational Qualifications","Family size",},
}

BASE_PATH = (
    "abfss://1b578a91-56d8-4afd-a1fe-ef5156c0cdbf"
    "@onelake.dfs.fabric.microsoft.com/"
    "9b24ad13-d48e-42e4-a3af-923d6bf3f4f4/"
    "Files/raw"
)

def sanitize_column_names(df):
    for old_name in df.columns:
        new_name = re.sub(r'[^0-9A-Za-z_]', '_', old_name)
        new_name = re.sub(r'_+', '_', new_name)
        new_name = new_name.strip('_')

        if old_name != new_name:
            df = df.withColumnRenamed(old_name, new_name)

    return df

def ingest_table(file_path: str, table_name: str, key_columns: list[str] | None = None) -> dict:
    loaded_at = datetime.utcnow().isoformat() # Thời điểm bắt đầu load dữ liệu 
    start_time = datetime.utcnow() # Lưu lại thời điểm logging

    #1 Check source file
    try:
        file_exists = len(dbutils.fs.ls(file_path)) >= 0 # kiểm tra source path 
    except Exception:
        file_exists = True # Tạm fallback; sau này sẽ cải thiện cách check path trong Fabric
    #2 Read CSV
    df = (
        spark.read
        .option("header", True)
        .option("inferSchema", False)
        .csv(file_path)
    )
    n_in = df.count() # Đếm số dòng đọc được từ CSV

    #3 Validate schema
    if table_name in EXPECTED_SCHEMAS:
        missing = EXPECTED_SCHEMAS[table_name] - set(df.columns) # Tìm các column bắt buộc nhưng CSV đang thiếu
        if missing:
            raise ValueError(f"{table_name}: thieu cot bat buoc {missing}")  # Thiếu column thì dừng ingestion

    df = sanitize_column_names(df)
    #4 Add ingestion metadata
    record_hash_cols = [c for c in df.columns]  # Lấy danh sách column gốc để tạo hash
    df = (
        df.withColumn("_ingested_at", F.lit(loaded_at).cast("timestamp"))  # Thời điểm record được ingest
          .withColumn("_source_file", F.lit(file_path)) # Lưu source file
          .withColumn("_run_id", F.lit(RUN_ID)) # Lưu ID của lần chạy
          .withColumn("_record_hash", F.sha2(F.concat_ws("|", *record_hash_cols), 256))  # Tạo hash cho record
    )
    #5 Validate basic records
    if n_in == 0:
        raise ValueError(f"{table_name}: file rong, dung ingestion")  # File rỗng thì dừng
    rows_rejected = 0  # Khởi tạo số record bị loại
    if key_columns:
        null_mask = " OR ".join(f"{k} IS NULL" for k in key_columns) # Tạo điều kiện tìm key NULL
        rows_rejected = df.filter(null_mask).count() # Đếm số record có key NULL
        if rows_rejected > 0:
            print(f"[CANH BAO] {table_name}: {rows_rejected} dong co khoa NULL, se bi loai")
            df = df.filter(f"NOT ({null_mask})")
    # 6 & 7. DETECT INCREMENTAL + WRITE DELTA TABLE
    if key_columns is None:
        df.write.format("delta") \
            .mode("overwrite") \
            .option("overwriteSchema", "true") \
            .saveAsTable(table_name)

        rows_inserted, rows_updated = df.count(), 0
    else:
        if not spark.catalog.tableExists(table_name):
            df.write.format("delta").mode("overwrite").saveAsTable(table_name)
            rows_inserted, rows_updated = df.count(), 0
        else:
            df.createOrReplaceTempView("_src")
            on_clause = " AND ".join(f"t.{k} = s.{k}" for k in key_columns)
            cols = ", ".join(df.columns)
            set_cols = ", ".join(f"t.{c} = s.{c}" for c in df.columns if c not in key_columns)
            # dem truoc de biet insert/update (MERGE khong tra ve con so nay truc tiep)
            existing_keys = spark.table(table_name).select(*key_columns)
            new_keys = df.select(*key_columns)
            rows_updated = new_keys.intersect(existing_keys).count()
            rows_inserted = new_keys.count() - rows_updated
            spark.sql(f"""
                MERGE INTO {table_name} t
                USING _src s
                ON {on_clause}
                WHEN MATCHED THEN UPDATE SET {set_cols}
                WHEN NOT MATCHED THEN INSERT ({cols}) VALUES ({cols})
            """)
    n_out = spark.table(table_name).count()
    end_time = datetime.utcnow()

    #8 Log ingestion result
    log_record = {
        "pipeline_name": "zomato_bronze_ingestion",
        "table_name": table_name,
        "run_id": RUN_ID,
        "start_time": start_time.isoformat(),
        "end_time": end_time.isoformat(),
        "status": "SUCCESS",
        "rows_read": n_in,
        "rows_inserted": rows_inserted,
        "rows_updated": rows_updated,
        "rows_rejected": rows_rejected,
        "error_message": "",
    }
    print(log_record)
    return log_record

tables = {
    "food": (f"{BASE_PATH}/food.csv","food_raw",None),
    "restaurants": (f"{BASE_PATH}/restaurant.csv","restaurants_raw",None),
    "users": (f"{BASE_PATH}/users.csv","users_raw",None),
    "reviews": (f"{BASE_PATH}/reviews.csv","reviews_raw",["review_id"]),
    "orders": (f"{BASE_PATH}/orders.csv","orders_raw",["order_id"]),
    "menu": (f"{BASE_PATH}/menu.csv","menu_raw",None),
    "order_items": (f"{BASE_PATH}/order_items.csv","order_items_raw", ["order_item_id"])
}

logs= []
for name, (path, table, keys) in tables.items():
    try:
        logs.append(ingest_table(path, table, keys))
    except Exception as e:
        logs.append({"pipeline_name": "zomato_bronze_ingestion", "table_name": table,
                      "run_id": RUN_ID, "status": "FAILED", "error_message": str(e)})
        raise  # dung hang neu 1 bang loi, khong am tham bo qua

spark.createDataFrame(logs).write.format("delta").mode("append").saveAsTable("etl_load_control")
    

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
