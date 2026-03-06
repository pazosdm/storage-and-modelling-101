# Exercise 09 – One Big Table for BI

## Overview

The "One Big Table" (OBT) pattern pre-joins all dimensions into a single flat table, optimizing for BI tools that benefit from fewer joins. You'll build an OBT from the star schema and then create an analytics view on top of it.

## Seed Data

```sql
-- Same star schema as Exercise 08:
-- dim_customer: 3 customers
-- dim_product: 3 products
-- fact_sales: 6 rows
```

## Tasks

1. Create a `sales_obt` table that pre-joins all dimensions into a single flat table. Include:
   - `order_id`, `order_date`, `customer_name`, `customer_city`, `customer_country`
   - `product_name`, `product_category`, `product_brand`
   - `quantity`, `unit_price`, `total_amount`

2. Populate it from `fact_sales`, `dim_customer`, and `dim_product`.

3. Create a view `v_monthly_category_revenue` on top of `sales_obt` that returns:
   - `year`, `month`, `product_category`, `total_revenue`
   - Ordered by `year`, `month`, `product_category`

## What to Submit

Write your solution in `solutions/ex09.sql`.

## Hints

- For the OBT, do a straightforward multi-table JOIN between `fact_sales`, `dim_customer`, and `dim_product`.
- For the monthly view, use `YEAR(order_date) AS year, MONTH(order_date) AS month` for grouping.
- `SUM(total_amount)` gives total revenue per group.
