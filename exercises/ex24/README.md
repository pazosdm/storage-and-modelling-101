# Exercise 24 – Hot/Cold Table Splitting

## Overview

Large fact tables grow indefinitely. A common data lifecycle pattern is to split them into "hot" (recent, frequently queried) and "cold" (historical, rarely queried) tables. This allows you to optimize storage and query performance for the hot data while archiving the cold data.

## Seed Data

```sql
-- fact_sales_full: 10,000 sales spanning ~5 years (2020-2024)
-- Dates: '2020-01-01' + (i % 1826) covers Jan 2020 to Dec 2024
```

## Tasks

1. Create `fact_sales_hot` containing only rows from the **last 6 months** relative to the max date in the table.

2. Create `fact_sales_cold` containing everything **older than 6 months**.

3. Create a view `v_fact_sales_all` that UNIONs both tables seamlessly.

4. Verify that `v_fact_sales_all` returns the same row count as the original (10,000 rows).

## What to Submit

Write your solution in `solutions/ex24.sql`.

## Hints

- Find the cutoff date first:
  ```sql
  SELECT MAX(sale_date) - INTERVAL 6 MONTH FROM fact_sales_full
  ```
- Use CTAS for both tables:
  ```sql
  CREATE TABLE fact_sales_hot AS SELECT * FROM fact_sales_full WHERE sale_date >= (SELECT MAX(sale_date) - INTERVAL 6 MONTH FROM fact_sales_full);
  ```
- The view: `CREATE VIEW v_fact_sales_all AS SELECT * FROM fact_sales_hot UNION ALL SELECT * FROM fact_sales_cold`
