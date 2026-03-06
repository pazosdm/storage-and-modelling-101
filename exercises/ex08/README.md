# Exercise 08 – Customer 360 Denormalized Table

## Overview

Build a pre-aggregated `customer_360` table that gives a complete picture of each customer's behavior: lifetime spend, order count, last order date, and favorite product category. This kind of table is common in CRM systems and marketing analytics.

## Seed Data

```sql
-- dim_customer: 3 customers (Alice, Bob, Carol)
-- dim_product: 3 products (Laptop/Electronics, Mouse/Peripherals, Monitor/Electronics)
-- fact_sales: 6 rows across 4 orders
```

## Tasks

1. Create a `customer_360` table with:
   - `customer_id`, `name`, `city`, `country`
   - `total_lifetime_sales` — sum of `total_amount`
   - `total_orders` — count of **distinct** `order_id`s
   - `last_order_date` — most recent `order_date`
   - `favorite_category` — category with the highest total spend

2. Populate it using a single query from `fact_sales`, `dim_customer`, and `dim_product`.

## What to Submit

Write your solution in `solutions/ex08.sql`.

## Hints

- Use a CTE to pre-aggregate sales per customer, then another CTE to find the favorite category using `ROW_NUMBER()`.
- For `favorite_category`, join `fact_sales` to `dim_product`, group by `(customer_id, category)`, then pick the max.
- `COUNT(DISTINCT order_id)` gives the correct total_orders count.
