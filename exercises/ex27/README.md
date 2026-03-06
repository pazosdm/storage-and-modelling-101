# Exercise 27 – Create and Evaluate Indexes

## Overview

Indexes speed up point lookups by allowing the database to jump directly to the relevant rows instead of scanning the entire table. In this exercise, you'll create an index on a 200,000-row table, capture the query plan before and after, and observe the effect.

## Seed Data

```sql
-- customer_events: 200,000 rows with customer_id, event_date, event_type, value
-- customer_id format: CUST-0000 through CUST-0499 (cycling every 500 rows)
```

## Tasks

1. Before creating the index, save the EXPLAIN output into a table:
   ```sql
   CREATE TABLE explain_no_index AS EXPLAIN SELECT * FROM customer_events WHERE customer_id = 'CUST-0042';
   ```

2. Create the index:
   ```sql
   CREATE INDEX idx_customer_events_cid ON customer_events(customer_id);
   ```

3. After the index, save the EXPLAIN output again:
   ```sql
   CREATE TABLE explain_with_index AS EXPLAIN SELECT * FROM customer_events WHERE customer_id = 'CUST-0042';
   ```

4. Write a query that counts total `'purchase'` events per `event_date` for January 2025.

## What to Submit

Write your solution in `solutions/ex27.sql`.

## Hints

- Note: DuckDB's ART indexes are primarily useful for point lookups on equality conditions.
- The EXPLAIN output is stored in a table with columns like `explain_value` — check the schema after creating it.
- Compare the two EXPLAIN tables to see whether the query plan changed.
