# Exercise 30 – Data Quality Checks and SLA Metrics

## Overview

Data quality monitoring is essential in production pipelines. Instead of checking issues row-by-row, you compute a **summary quality report** in a single SQL statement. This pattern is common in data observability tools.

## Seed Data

```sql
-- fact_daily_sales: 8 rows with intentional quality issues:
-- Row 2: NULL amount
-- Row 3: Duplicate of row 1
-- Row 5: NULL customer_id
-- Row 6: Late load (loaded at 14:00 instead of 06:00)
-- Row 7: Negative amount (-50.00)
```

## Tasks

1. Create a `dq_report` table with these columns:
   - `total_rows` INTEGER
   - `null_amount_count` INTEGER
   - `null_customer_count` INTEGER
   - `duplicate_count` INTEGER — rows where (sale_date, customer_id, product_id, amount) appears more than once
   - `negative_amount_count` INTEGER — rows where amount < 0
   - `late_load_count` INTEGER — rows where `loaded_at` time > 08:00 on the `sale_date`
   - `completeness_pct` DECIMAL — % of rows with no NULLs in amount or customer_id
   - `validity_pct` DECIMAL — % of rows where amount >= 0 (among non-NULL amounts)

2. Populate it with a **single INSERT ... SELECT** from `fact_daily_sales`.

## What to Submit

Write your solution in `solutions/ex30.sql`.

## Hints

- Use conditional aggregation:
  ```sql
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount_count,
  COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_count,
  COUNT(*) FILTER (WHERE amount < 0) AS negative_amount_count,
  COUNT(*) FILTER (WHERE HOUR(loaded_at) >= 8) AS late_load_count
  ```
- For `duplicate_count`: use a subquery to find rows where the (sale_date, customer_id, product_id, amount) group has COUNT(*) > 1, then count those extra rows.
- `completeness_pct = 100.0 * COUNT(*) FILTER (WHERE amount IS NOT NULL AND customer_id IS NOT NULL) / COUNT(*)`
- `late_load_count`: load is "late" if `loaded_at::TIME > '08:00:00'`
