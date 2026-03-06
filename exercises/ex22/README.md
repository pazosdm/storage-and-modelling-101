# Exercise 22 – Partitioned Parquet Export

## Overview

Partitioned Parquet files are a cornerstone of lake-house architectures. DuckDB can write Parquet files partitioned by one or more columns, creating a folder structure where each partition is a separate file. This enables partition pruning — reading only the relevant partition instead of the full dataset.

## Seed Data

```sql
CREATE TABLE event_log (event_id INTEGER, event_date DATE, country VARCHAR, event_type VARCHAR, value DECIMAL(10,2));
-- 8 events across 3 dates (Jan 10, 11, 12) and 2 countries (BR, US)
```

## Tasks

1. Export `event_log` to Parquet partitioned by `event_date`:
   ```sql
   COPY event_log TO '/tmp/ex22_partitioned' (FORMAT PARQUET, PARTITION_BY (event_date));
   ```

2. Read back **only** the partition for `2025-01-11` into a table called `events_jan11`:
   ```sql
   CREATE TABLE events_jan11 AS SELECT * FROM read_parquet('/tmp/ex22_partitioned/event_date=2025-01-11/*.parquet');
   ```

3. Write a query that returns total value per country for the Jan 11 partition.

## What to Submit

Write your solution in `solutions/ex22.sql`.

## Hints

- DuckDB creates a directory structure like `/tmp/ex22_partitioned/event_date=2025-01-11/data_0.parquet`
- The partition key (event_date) is encoded in the folder name and included as a column when reading back.
