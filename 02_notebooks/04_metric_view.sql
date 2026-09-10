%sql
CREATE OR REPLACE VIEW retail_q.retail_semantic.sample_metric_view
WITH METRICS
LANGUAGE YAML
AS $$
version: 1.1
source: retail_q.retail_gold.fact_sales
comment: Retail sales metrics with product, customer, and calendar dimensions for comprehensive sales analysis
joins:
  - name: products
    source: retail_q.retail_gold.dim_product
    on: source.product_id = products.product_id
  - name: customers
    source: retail_q.retail_gold.dim_customer
    on: source.customer_id = customers.customer_id
  - name: calendar
    source: retail_q.retail_gold.dim_calendar
    on: source.transaction_date = calendar.date
dimensions:
  - name: Transaction Month
    expr: DATE_TRUNC('MONTH', transaction_date)
    display_name: Transaction Month
    comment: Month when the transaction occurred
    format:
      type: date
      date_format: year_month_day
    synonyms:
      - sale month
      - order month
  - name: Transaction Year
    expr: calendar.year
    display_name: Transaction Year
    comment: Year when the transaction occurred
    synonyms:
      - sale year
      - order year
  - name: Transaction Quarter
    expr: calendar.year_quarter
    display_name: Transaction Quarter
    comment: Year and quarter of the transaction (e.g. 2024-Q1)
    synonyms:
      - quarter
      - fiscal quarter
  - name: Day of Week
    expr: calendar.day_of_week_name
    display_name: Day of Week
    comment: Day of the week when the transaction occurred
    synonyms:
      - weekday
      - day name
  - name: Weekend Flag
    expr: calendar.is_weekend
    display_name: Is Weekend
    comment: Whether the transaction occurred on a weekend
    synonyms:
      - weekend
      - weekend indicator
  - name: Product Category
    expr: products.category
    display_name: Product Category
    comment: Product category from product dimension
    synonyms:
      - category
      - product type
  - name: Product Subcategory
    expr: products.subcategory
    display_name: Product Subcategory
    comment: Product subcategory from product dimension
    synonyms:
      - subcategory
      - sub type
  - name: Product Brand
    expr: products.brand
    display_name: Product Brand
    comment: Brand of the product sold
    synonyms:
      - brand
      - manufacturer
  - name: Product Segment
    expr: products.product_segment
    display_name: Product Segment
    comment: Market segment of the product
    synonyms:
      - segment
      - product tier
  - name: Customer State
    expr: customers.billing_state
    display_name: Customer State
    comment: Customer billing state location
    synonyms:
      - state
      - location
      - region
  - name: Customer City
    expr: customers.billing_city
    display_name: Customer City
    comment: Customer billing city location
    synonyms:
      - city
      - customer location
  - name: Customer Type
    expr: customers.customer_type
    display_name: Customer Type
    comment: Type of customer (e.g. Enterprise, Individual)
    synonyms:
      - customer category
      - account type
  - name: Customer Industry
    expr: customers.industry
    display_name: Customer Industry
    comment: Industry the customer belongs to
    synonyms:
      - industry
      - sector
  - name: Sales Channel
    expr: sales_channel
    display_name: Sales Channel
    comment: Channel through which sale was made (Online or Store)
    synonyms:
      - channel
      - sales type
  - name: Payment Mode
    expr: payment_mode
    display_name: Payment Mode
    comment: Payment method used for transaction
    synonyms:
      - payment method
      - payment type
measures:
  - name: Total Sales Revenue
    expr: SUM(selling_price * quantity)
    display_name: Total Sales Revenue
    comment: Total revenue from sales before discounts
    format:
      type: currency
      currency_code: INR
      decimal_places:
        type: exact
        places: 2
    synonyms:
      - revenue
      - sales
      - total sales
  - name: Total Discount
    expr: SUM(discount_amount)
    display_name: Total Discount
    comment: Total discount amount applied to transactions
    format:
      type: currency
      currency_code: INR
      decimal_places:
        type: exact
        places: 2
    synonyms:
      - discount
      - discounts given
  - name: Transaction Count
    expr: COUNT(1)
    display_name: Transaction Count
    comment: Total number of transactions
    synonyms:
      - order count
      - number of orders
      - sales count
  - name: Average Order Value
    expr: SUM(selling_price * quantity) / COUNT(1)
    display_name: Average Order Value
    comment: Average revenue per transaction
    format:
      type: currency
      currency_code: INR
      decimal_places:
        type: exact
        places: 2
    synonyms:
      - AOV
      - avg order size
  - name: Net Revenue
    expr: SUM((selling_price * quantity) - discount_amount)
    display_name: Net Revenue
    comment: Total revenue after discounts
    format:
      type: currency
      currency_code: INR
      decimal_places:
        type: exact
        places: 2
    synonyms:
      - net sales
      - revenue after discount
  - name: Total Quantity Sold
    expr: SUM(quantity)
    display_name: Total Quantity Sold
    comment: Total number of units sold across all transactions
    format:
      type: number
      decimal_places:
        type: exact
        places: 0
    synonyms:
      - units sold
      - total quantity
      - volume
  - name: Unique Customers
    expr: COUNT(DISTINCT customer_id)
    display_name: Unique Customers
    comment: Number of distinct customers who made purchases
    format:
      type: number
      decimal_places:
        type: exact
        places: 0
    synonyms:
      - distinct customers
      - customer count
      - unique buyers
$$