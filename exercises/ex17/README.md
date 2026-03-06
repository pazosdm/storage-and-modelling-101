# Exercise 17 – Conformed Dimensions Across Fact Tables

## Overview

**Conformed dimensions** are shared across multiple fact tables, allowing you to combine data from different business processes. Here, `dim_date_conf` and `dim_product_conf` are shared between sales and returns, enabling a "drill-across" query that joins both fact tables via their shared dimensions.

## Seed Data

```sql
-- dim_date_conf: January–March 2025 date spine (91 days)
-- dim_product_conf: 3 products (Widget A/Gadgets, Widget B/Tools, Widget C/Gadgets)
-- raw_sales: 4 sales (Jan and Feb)
-- raw_returns: 2 returns (Jan and Feb)
```

## Tasks

1. Create `fact_sales_conf` (sale_id, product_id FK, sale_date FK to dim_date, revenue)
2. Create `fact_returns_conf` (return_id, product_id FK, return_date FK to dim_date, refund_amount)
3. Write a **drill-across query** that shows by month and category:
   - `total_revenue`, `total_refunds`, `net_revenue` (revenue - refunds)
   - Name it as a view `v_drill_across` (optional, for your reference)

## What to Submit

Write your solution in `solutions/ex17.sql`.

## Hints

- A drill-across joins aggregated results from each fact table separately, then JOINs them on the conformed dimension keys.
- Use CTEs: `WITH sales_agg AS (...), returns_agg AS (...)` then `SELECT ... FROM sales_agg FULL OUTER JOIN returns_agg ON ...`
- `COALESCE(total_refunds, 0)` handles months/categories with no returns.
