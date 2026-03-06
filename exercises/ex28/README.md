# Exercise 28 – Columnar Scan Optimization

## Overview

Wide tables with many columns cause full column reads even when queries only need a few columns. In DuckDB's columnar storage, splitting a wide table into a narrow "core" projection and an "extended attributes" table means analytical queries only read the columns they need.

## Seed Data

```sql
-- wide_events: 50,000 rows with analytical columns (event_id, date, user, type, amount)
-- plus large payload columns (col_a, col_b, col_c) and a hash column
```

## Tasks

1. Create `events_core` with only the frequently queried columns:
   - `event_id`, `event_date`, `user_id`, `event_type`, `amount`

2. Create `events_extended` with the remaining columns:
   - `event_id`, `col_a`, `col_b`, `col_c`, `hash_col`

3. Populate both from `wide_events`.

4. Write a query that computes **total purchase amount per month** using only `events_core`.

5. Write a query that joins `events_core` and `events_extended` for a specific `event_id` to demonstrate on-demand access to extended columns.

## What to Submit

Write your solution in `solutions/ex28.sql`.

## Hints

- `CREATE TABLE events_core AS SELECT event_id, event_date, user_id, event_type, amount FROM wide_events`
- `CREATE TABLE events_extended AS SELECT event_id, col_a, col_b, col_c, hash_col FROM wide_events`
- Monthly purchase amount: `WHERE event_type = 'purchase' GROUP BY YEAR(event_date), MONTH(event_date)`
