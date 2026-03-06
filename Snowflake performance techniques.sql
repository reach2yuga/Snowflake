Snowflake performance techniques
-----------------------------------------------------------------------------------
1.Proper Virtual Warehouse Sizing
If queries are slow due to insufficient compute, increase warehouse size.
SELECT *
FROM large_sales_table
WHERE sales_date > '2025-01-01';

If warehouse is X-Small, query may take 10 minutes.

ALTER WAREHOUSE analytics_wh
SET WAREHOUSE_SIZE = LARGE;

Result:
More CPU and memory
Query may run in 2 minutes instead of 10 minutes

Use when:
Large joins
Heavy aggregations
Complex transformations

----------------------------------------------------------------------------
2. Use Clustering Keys
Snowflake stores data in micro-partitions.
Clustering organizes data so queries scan fewer partitions.

CREATE TABLE sales (
order_id INT,
customer_id INT,
order_date DATE,
amount NUMBER
);

SELECT *
FROM sales
WHERE order_date = '2025-03-01';

ALTER TABLE sales
CLUSTER BY (order_date);

| Before                 | After                 |
| ---------------------- | --------------------- |
| 500 partitions scanned | 20 partitions scanned |
----------------------------------------------------------------------------------
3 Use Result Cache
Snowflake automatically caches query results for 24 hours.

SELECT SUM(amount)
FROM sales;

Second user runs same query.

Result:
Snowflake returns cached result instantly
No warehouse compute used

Conditions:
Query text must be identical
Data must not change
---------------------------------------------------------------------------------------
4 Use Search Optimization Service
Improves point lookup queries.

SELECT *
FROM customers
WHERE email = 'abc@gmail.com';

ALTER TABLE customers
ADD SEARCH OPTIMIZATION
ON EQUALITY(email);

| Before          | After         |
| --------------- | ------------- |
| Full table scan | Direct lookup |

Query time drops from 10 sec → 0.3 sec.
--------------------------------------------------------------------------------------
5 Query Acceleration Service
Adds extra compute temporarily to speed up large scans.

Query scanning billions of rows:

SELECT customer_id, SUM(amount)
FROM transactions
GROUP BY customer_id;

ALTER WAREHOUSE analytics_wh
SET QUERY_ACCELERATION = TRUE;

Result:
Extra compute nodes process data
Query becomes 3–5x faster
-----------------------------------------------------------------
6 Use Proper File Formats for Loading
Columnar formats improve performance.

Best formats:
Parquet
ORC

COPY INTO sales
FROM @stage/sales.parquet
FILE_FORMAT = (TYPE = PARQUET);

Benefits:
Faster loading
Better compression
Faster queries
--------------------------------------------------------------------------------------
7 Avoid SELECT *
Bad practice:
SELECT *
FROM sales;

Better:
SELECT order_id, amount
FROM sales;

Snowflake reads only required columns.

Result:
Less data scanned
Faster query
-------------------------------------------------------------------------------------------------
8 Use Materialized Views

CREATE MATERIALIZED VIEW mv_sales
AS
SELECT region, SUM(amount) total_sales
FROM sales
GROUP BY region;


SELECT *
FROM mv_sales;

Result:
No need to recompute aggregation
Query becomes very fast
-------------------------------------------------------------------------------------------
9 Optimize Joins

SELECT *
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

SELECT *
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_date = '2025-03-01';

Result:
Smaller dataset
Faster joins
---------------------------------------------------------------------------------------------------
🔟 Use Micro-Partition Pruning
Snowflake automatically scans only relevant partitions.

SELECT *
FROM sales_data
WHERE order_date = '2025-03-01';

| Before       | After         |
| ------------ | ------------- |
| 1 TB scanned | 20 GB scanned |

