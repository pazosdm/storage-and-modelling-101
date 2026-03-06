# Exercise 13 – SCD Type 2 (Preserve History)

## Overview

SCD Type 2 preserves the full history of dimension changes. Each time an attribute changes, the old record is "closed" (valid_to updated, is_current set to false) and a new record is inserted. This allows you to look up the state of a dimension at any point in time.

## Seed Data

```sql
-- dim_customer_scd2: 3 customers (all currently open)
-- seq_customer_sk: sequence starting at 4 for new surrogate keys
-- stg_customer_daily: C001 changed (city+segment), C002 unchanged, C004 is new
```

## Tasks

1. Implement SCD Type 2 logic against `dim_customer_scd2`:
   - For **changed** customers (C001): close current record (set `valid_to` = load_date - 1, `is_current` = false); insert new record with `valid_from` = load_date, `valid_to` = '9999-12-31', `is_current` = true
   - For **unchanged** customers (C002): do nothing
   - For **new** customers (C004): insert with `valid_from` = load_date, `is_current` = true

2. Use `nextval('seq_customer_sk')` for new surrogate keys.

## What to Submit

Write your solution in `solutions/ex13.sql`.

## Hints

- First, `UPDATE dim_customer_scd2 SET valid_to = '2025-01-31', is_current = false WHERE customer_id = 'C001' AND is_current = true`
- Then `INSERT INTO dim_customer_scd2 VALUES (nextval('seq_customer_sk'), 'C001', ..., '2025-02-01', '9999-12-31', true)`
- Compare old vs new to detect changes: `WHERE d.city != s.city OR d.segment != s.segment`
- `valid_to = load_date - INTERVAL 1 DAY` computes the day before load_date.
