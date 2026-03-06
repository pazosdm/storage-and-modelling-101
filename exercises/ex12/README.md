# Exercise 12 – SCD Type 1 (Overwrite)

## Overview

Slowly Changing Dimension Type 1 (SCD1) is the simplest approach: when an attribute changes, you simply overwrite it. No history is preserved. This is useful when the old value is irrelevant (e.g., fixing a typo, updating a phone number).

## Seed Data

```sql
-- dim_product: 3 products with an updated_at date
-- stg_product_updates: 3 changes — product 2 renamed, product 3 recategorized, product 4 is new
```

## Tasks

1. Apply SCD Type 1 logic to `dim_product`:
   - **Update** existing products where attributes changed — overwrite with new values and update `updated_at`
   - **Insert** new products that don't exist yet

2. After execution, `dim_product` should reflect the latest state with **no history preserved**.

## What to Submit

Write your solution in `solutions/ex12.sql`.

## Hints

- For updates, use `UPDATE dim_product SET product_name = s.product_name, ... FROM stg_product_updates s WHERE dim_product.product_id = s.product_id AND (dim_product.product_name != s.product_name OR dim_product.category != s.category OR ...)`
- For inserts, use `INSERT INTO dim_product SELECT ... FROM stg_product_updates s WHERE NOT EXISTS (SELECT 1 FROM dim_product d WHERE d.product_id = s.product_id)`
- Or use DuckDB's `INSERT OR REPLACE` / `ON CONFLICT DO UPDATE` syntax.
