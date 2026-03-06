# Exercise 21 – Read and Write Multiple File Formats

## Overview

DuckDB has first-class support for reading and writing multiple file formats. This exercise covers the three most common: CSV, Parquet, and JSON. You'll export data to each format, then read it back to verify round-trip fidelity.

## Seed Data

```sql
CREATE TABLE sample_data (id INTEGER, name VARCHAR, amount DECIMAL(10,2), event_date DATE);
-- 4 rows: Alice (100.50), Bob (200.75), Carol (300.00), Diana (150.25)
```

## Tasks

1. Export `sample_data` to CSV:
   ```sql
   COPY sample_data TO '/tmp/ex21_output.csv' (HEADER, DELIMITER ',');
   ```

2. Export `sample_data` to Parquet:
   ```sql
   COPY sample_data TO '/tmp/ex21_output.parquet' (FORMAT PARQUET);
   ```

3. Export `sample_data` to JSON:
   ```sql
   COPY sample_data TO '/tmp/ex21_output.json' (FORMAT JSON, ARRAY true);
   ```

4. Read each file back into a new table:
   ```sql
   CREATE TABLE csv_reimport AS SELECT * FROM read_csv_auto('/tmp/ex21_output.csv');
   CREATE TABLE parquet_reimport AS SELECT * FROM read_parquet('/tmp/ex21_output.parquet');
   CREATE TABLE json_reimport AS SELECT * FROM read_json_auto('/tmp/ex21_output.json');
   ```

5. Verify all three have the same row count and total amount.

## What to Submit

Write your solution in `solutions/ex21.sql`.
