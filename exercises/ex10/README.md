# Exercise 10 – Views vs Precomputed Summary Tables

## Overview

Explore the tradeoff between a live view (always up-to-date, but computed on query) and a precomputed summary table (fast to read, but requires refresh). Both patterns are common in data warehouses.

## Seed Data

```sql
-- Same star schema as Exercise 08:
-- dim_customer: 3 customers
-- dim_product: 3 products
-- fact_sales: 6 rows across 4 distinct dates
```

## Tasks

1. Create a **view** `v_daily_revenue` that computes daily total revenue from `fact_sales`:
   - Columns: `order_date`, `total_revenue`

2. Create a **table** `summary_daily_revenue` with the same content (precomputed using CTAS):
   - `CREATE TABLE summary_daily_revenue AS SELECT ...`

3. Create a **table** `summary_monthly_store_revenue` that aggregates revenue by month and customer country:
   - Columns: `year`, `month`, `country`, `total_revenue`, `total_orders`
   - Join `fact_sales` with `dim_customer` to get the country

## What to Submit

Write your solution in `solutions/ex10.sql`.

## Hints

- `CREATE VIEW v_daily_revenue AS SELECT order_date, SUM(total_amount) AS total_revenue FROM fact_sales GROUP BY order_date`
- `CREATE TABLE summary_daily_revenue AS SELECT * FROM v_daily_revenue`
- For monthly revenue, use `YEAR(order_date)` and `MONTH(order_date)`.
- `total_orders = COUNT(DISTINCT order_id)`
