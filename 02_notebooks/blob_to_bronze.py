# Read all CSV files from the volume location
df = spark.read \
  .format("csv") \
  .option("header", "true") \
  .option("inferSchema", "true") \
  .load("/Volumes/retail_q/volumes/s3_source/transactions_source/*.csv")

# Write to bronze table
df.write \
  .mode("overwrite") \
  .saveAsTable("retail_q.blob_bronze.transactions")

print(f"✓ Successfully loaded {df.count()} records to retail_q.blob_bronze.transactions")

%sql
select count(*) from retail_q.blob_bronze.transactions