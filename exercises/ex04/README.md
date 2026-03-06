# Exercise 04 – Normalization vs Query Complexity

## Overview

You are given a deeply normalized schema: customers reference cities, cities reference countries, and sales reference customers. While this is great for storage efficiency, analytical queries require multiple joins. In this exercise you'll see that tradeoff firsthand by creating views and a denormalized table.

## Seed Data

```sql
CREATE TABLE dim_customer (customer_id INTEGER PRIMARY KEY, customer_name VARCHAR, city_id INTEGER);
CREATE TABLE dim_city (city_id INTEGER PRIMARY KEY, city_name VARCHAR, country_id INTEGER);
CREATE TABLE dim_country (country_id INTEGER PRIMARY KEY, country_name VARCHAR, region VARCHAR);
CREATE TABLE fact_sales (order_id INTEGER PRIMARY KEY, customer_id INTEGER, order_date DATE, amount DECIMAL(10,2));
-- 5 customers, 4 cities, 3 countries, 10 sales rows
```

## Tasks

1. Create a view `v_sales_by_country` that returns `country_name` and `total_sales` (sum of amount), ordered by `total_sales` descending.

2. Create a view `v_top_customers_by_country` that returns `country_name`, `customer_name`, `total_sales`, and `rank_in_country` (rank within each country by sales, descending). Use `RANK()`.

3. Create a denormalized table `dim_customer_flat` that flattens customer → city → country into a single table:
   - Columns: `customer_id`, `customer_name`, `city_name`, `country_name`, `region`
   - Populate it.

## What to Submit

Write your solution in `solutions/ex04.sql`.

## Hints

- For views with window functions, use `WITH` (CTEs) or a subquery.
- `RANK()` requires `OVER (PARTITION BY country_name ORDER BY total_sales DESC)`.
- The `dim_customer_flat` is populated with `INSERT INTO ... SELECT ... FROM dim_customer JOIN dim_city ... JOIN dim_country ...`.
