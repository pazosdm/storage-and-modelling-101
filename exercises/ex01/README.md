# Exercise 01 – Normalize a Wide Table to 3NF

## Overview

You are given a denormalized staging table `stg_orders` that contains order, customer, product, and store data all in one row. Your job is to decompose it into a proper Third Normal Form (3NF) schema.

## Seed Data

```sql
CREATE TABLE stg_orders (
    order_id         INTEGER,
    order_date       DATE,
    customer_id      INTEGER,
    customer_name    VARCHAR,
    customer_email   VARCHAR,
    customer_city    VARCHAR,
    product_id       INTEGER,
    product_name     VARCHAR,
    product_category VARCHAR,
    unit_price       DECIMAL(10,2),
    quantity         INTEGER,
    store_id         INTEGER,
    store_name       VARCHAR,
    store_city       VARCHAR
);
-- (6 rows of sample data)
```

## Tasks

1. Create the following normalized tables from `stg_orders`:
   - `customers` (customer_id PK, customer_name, customer_email, customer_city)
   - `products` (product_id PK, product_name, product_category, unit_price)
   - `stores` (store_id PK, store_name, store_city)
   - `orders` (order_id PK, order_date, customer_id FK, product_id FK, store_id FK, quantity)

2. Populate each table using `INSERT INTO ... SELECT DISTINCT ...` from `stg_orders`.

3. Ensure no duplicate rows exist in any dimension table.

## What to Submit

Write your solution in `solutions/ex01.sql`. The file should contain the `CREATE TABLE` and `INSERT INTO ... SELECT` statements.

## Hints

- Use `SELECT DISTINCT` when extracting customer/product/store data to avoid duplicates.
- The `orders` table should keep the original `quantity` from `stg_orders` (not deduplicated).
- Think about what makes each row unique in each table (the primary key).
