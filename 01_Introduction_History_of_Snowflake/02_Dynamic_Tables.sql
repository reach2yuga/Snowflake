Scenario: E-Commerce Sales Dashboard
Objective

Keep a table of daily sales metrics updated automatically, including:

Total sales per product

Total sales per category

Revenue trends per day

The data comes from raw transactional tables (orders, order_items, products) in Snowflake. You want incremental updates without running full batch jobs manually.

Pipeline Design
Step 1: Raw Tables

orders(order_id, order_date, customer_id, status)

order_items(order_item_id, order_id, product_id, quantity, price)

products(product_id, product_name, category)

These are source tables that receive continuous updates.

Step 2: Create a Dynamic Table for Order Aggregates
CREATE OR REPLACE DYNAMIC TABLE daily_product_sales
TARGET_LAG = '10 minutes'
WAREHOUSE = analytics_wh
REFRESH_MODE = AUTO
AS
SELECT 
    o.order_date,
    p.product_id,
    p.category,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'COMPLETED'
GROUP BY o.order_date, p.product_id, p.category;

Explanation:

Automatically refreshes every 10 minutes (TARGET_LAG).

Only incremental changes are processed (new orders are added, cancelled orders are removed).

No manual ETL job needed.

Step 3: Build Another Dynamic Table for Category-Level Metrics
CREATE OR REPLACE DYNAMIC TABLE daily_category_sales
TARGET_LAG = '15 minutes'
WAREHOUSE = analytics_wh
REFRESH_MODE = AUTO
AS
SELECT 
    order_date,
    category,
    SUM(total_quantity) AS category_quantity,
    SUM(total_revenue) AS category_revenue
FROM daily_product_sales
GROUP BY order_date, category;

Explanation:

Depends on the first dynamic table (daily_product_sales).

Aggregates data at the category level.

Automatically updates whenever daily_product_sales updates.

Step 4: Optional Dashboard Table
CREATE OR REPLACE DYNAMIC TABLE sales_dashboard
TARGET_LAG = '20 minutes'
WAREHOUSE = analytics_wh
REFRESH_MODE = AUTO
AS
SELECT 
    order_date,
    category,
    category_quantity,
    category_revenue,
    ROUND(category_revenue / category_quantity, 2) AS avg_price
FROM daily_category_sales;

Explanation:

Combines metrics into a ready-to-query table for dashboards.

Supports BI tools like Tableau, Looker, or Power BI directly.

Fully automated with target freshness control.

Step 5: Optional Optimizations

Add immutability constraints if you want to freeze historical dates.

Monitor refresh performance in the Snowflake UI.

Break complex logic into multiple dynamic tables for incremental refresh efficiency.

✅ Benefits of this pipeline

Fully automated, declarative refresh.

No custom scheduling needed.

Incremental updates reduce compute cost.

Easy to extend with more derived tables (e.g., weekly or monthly metrics).