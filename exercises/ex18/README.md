# Exercise 18 – Inmon 3NF vs Kimball Star: Build Both

## Overview

Two dominant approaches to data warehouse design are:
- **Inmon**: Build a normalized enterprise data warehouse (EDW) in 3NF first, then create data marts on top
- **Kimball**: Build dimensional star schemas (fact + dimension tables) directly

In this exercise, you'll implement the same business data using both approaches and write the same analytical query against each.

## Seed Data

```sql
-- src_transactions: 5 denormalized transactions
-- Customers: Alice (Brazil), Bob (Brazil), Carol (USA)
-- Products: Laptop, Mouse, Monitor
```

## Tasks

1. **Inmon approach** — create normalized 3NF tables:
   - `inmon_customers` (customer_id, customer_name, customer_city, customer_country)
   - `inmon_products` (product_id, product_name, category)
   - `inmon_transactions` (txn_id, customer_id FK, product_id FK, txn_date, quantity, amount)

2. **Kimball approach** — create star schema:
   - `kimball_dim_customer` (customer_id, customer_name, customer_city, customer_country)
   - `kimball_dim_product` (product_id, product_name, category)
   - `kimball_fact_sales` (txn_id, customer_id, product_id, txn_date, quantity, amount)

3. Write the same business query against both models: **total amount by country**
   - Name the views `v_inmon_by_country` and `v_kimball_by_country`
   - Both should return: `country`, `total_amount` ordered by country

## What to Submit

Write your solution in `solutions/ex18.sql`.

## Hints

- The data model structures look similar, but the Inmon version requires proper FKs declared via `FOREIGN KEY (col) REFERENCES table(col)`.
- Views should use: `SELECT country_name AS country, SUM(amount) AS total_amount FROM inmon_transactions JOIN inmon_customers ... GROUP BY country ORDER BY country`
- Use `customer_country` as the column name — both approaches use the same alias.
