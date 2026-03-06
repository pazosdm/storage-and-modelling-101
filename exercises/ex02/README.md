# Exercise 02 – Identify and Fix Anomalies

## Overview

The staging table `stg_orders` has a known **update anomaly**: customer 101 (Alice) appears with two different email addresses. This happens in denormalized tables when the same entity is represented in multiple rows and one row gets updated while others don't.

Your job is to normalize the table while resolving the anomaly correctly.

## Seed Data

```sql
CREATE TABLE stg_orders (...);
-- 7 rows — Alice appears in rows 1, 3, and 7 with different emails.
-- Row 7 (order_date='2025-01-20') has Alice's new email: alice.new@mail.com
-- Rows 1 and 3 have the old email: alice@mail.com
```

## Tasks

1. Create normalized tables `customers`, `products`, `stores`, and `orders` with proper **PRIMARY KEY** and **NOT NULL** constraints.

2. For customers with multiple emails (like Alice), keep only the **most recent** email (based on the latest `order_date`).

3. Populate all tables, ensuring constraints are satisfied.

## What to Submit

Write your solution in `solutions/ex02.sql`.

## Hints

- To pick the most recent email per customer, use a subquery with `ROW_NUMBER()` ordered by `order_date DESC`, or use `LAST_VALUE` / aggregation to pick the email from the most recent row.
- A simple approach: `SELECT DISTINCT ON (customer_id) customer_id, customer_name, customer_email, customer_city FROM stg_orders ORDER BY customer_id, order_date DESC`
- DuckDB supports `SELECT DISTINCT ON (...)` similar to PostgreSQL.
