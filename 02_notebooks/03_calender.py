from pyspark.sql import functions as F
from datetime import datetime

# Get parameters from widgets
start_date_str = dbutils.widgets.get("start_date")
end_date_str = dbutils.widgets.get("end_date")

start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
end_date = datetime.strptime(end_date_str, '%Y-%m-%d')

# Generate date range
date_df = spark.sql(f"""
  SELECT sequence(
    to_date('{start_date.strftime('%Y-%m-%d')}'), 
    to_date('{end_date.strftime('%Y-%m-%d')}'),
    interval 1 day
  ) as date_array
""").selectExpr("explode(date_array) as date")

# Create calendar dimension with standard attributes
calendar_df = date_df.select(
    F.col("date"),
    F.year("date").alias("year"),
    F.month("date").alias("month"),
    F.date_format("date", "MMMM").alias("month_name"),
    F.date_format("date", "MMM").alias("month_short_name"),
    F.quarter("date").alias("quarter"),
    F.weekofyear("date").alias("week_of_year"),
    F.dayofweek("date").alias("day_of_week"),  # 1=Sunday, 7=Saturday
    F.date_format("date", "EEEE").alias("day_of_week_name"),
    F.date_format("date", "EEE").alias("day_of_week_short_name"),
    F.dayofmonth("date").alias("day_of_month"),
    F.dayofyear("date").alias("day_of_year"),
    F.when(F.dayofweek("date").isin([1, 7]), True).otherwise(False).alias("is_weekend"),
    F.when(F.dayofweek("date").isin([1, 7]), False).otherwise(True).alias("is_weekday"),
    # Fiscal year (assuming fiscal year starts in April, adjust as needed)
    F.when(F.month("date") >= 4, F.year("date")).otherwise(F.year("date") - 1).alias("fiscal_year"),
    F.when(F.month("date").isin([4, 5, 6]), 1)
     .when(F.month("date").isin([7, 8, 9]), 2)
     .when(F.month("date").isin([10, 11, 12]), 3)
     .otherwise(4).alias("fiscal_quarter"),
    # Date formatting variants
    F.date_format("date", "yyyy-MM-dd").alias("date_string"),
    F.date_format("date", "yyyyMM").alias("year_month"),
    F.date_format("date", "yyyyQQ").alias("year_quarter")
)

# Write to table
calendar_df.write \
    .mode("overwrite") \
    .format("delta") \
    .saveAsTable("retail_q.retail_gold.calendar")

print(f"✓ Calendar table created successfully!")
print(f"  Date range: {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
print(f"  Total records: {calendar_df.count():,}")