# Exercise 07 – Build a Star Schema from 3NF

## Overview

Transform a normalized OLTP schema (3NF) into a dimensional star schema suitable for analytics. You have four OLTP tables and need to produce dimension tables and a fact table.

## Seed Data

```sql
CREATE TABLE oltp_customers (customer_id, name, email, city, state, country);
CREATE TABLE oltp_products (product_id, product_name, category, brand, unit_price);
CREATE TABLE oltp_orders (order_id, customer_id, order_date, status);
CREATE TABLE oltp_order_items (order_id, product_id, quantity, unit_price);
-- 3 customers, 3 products, 4 orders, 6 order items
```

## Tasks

1. Create `dim_customer` (customer_id, name, email, city, state, country)
2. Create `dim_product` (product_id, product_name, category, brand)
3. Create `dim_date` with grain = one day: date_key (DATE), year, month, day, day_of_week — populate it for all days in January and February 2025
4. Create `fact_sales` with grain = one row per order line item:
   - order_id, customer_id, product_id, order_date, quantity, unit_price, total_amount (quantity * unit_price)
5. Populate `fact_sales` from the OLTP tables

## What to Submit

Write your solution in `solutions/ex07.sql`.

## Hints

- For `dim_date`, use `generate_series('2025-01-01'::DATE, '2025-02-28'::DATE, INTERVAL 1 DAY)`.
- `YEAR(date_key)`, `MONTH(date_key)`, `DAY(date_key)`, `DAYOFWEEK(date_key)` extract components.
- `fact_sales` is populated by joining `oltp_orders` and `oltp_order_items`.
- `total_amount = quantity * unit_price` (use the price from `oltp_order_items`, not `oltp_products`).
