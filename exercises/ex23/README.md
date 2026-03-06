# Exercise 23 – Compression Comparison

## Overview

Parquet supports multiple compression codecs, each with different tradeoffs between compression ratio, write speed, and read speed. SNAPPY is fast with moderate compression, ZSTD has better compression with slightly more CPU, and UNCOMPRESSED is largest but requires no decompression.

## Seed Data

```sql
-- large_data: 100,000 rows generated with generate_series
-- Columns: id, user_id, event_date, event_type, amount
```

## Tasks

1. Export `large_data` to three Parquet files with different compression:
   ```sql
   COPY large_data TO '/tmp/ex23_snappy.parquet' (FORMAT PARQUET, COMPRESSION SNAPPY);
   COPY large_data TO '/tmp/ex23_zstd.parquet' (FORMAT PARQUET, COMPRESSION ZSTD);
   COPY large_data TO '/tmp/ex23_none.parquet' (FORMAT PARQUET, COMPRESSION UNCOMPRESSED);
   ```

2. Create a table `compression_comparison` with columns: `compression_type` (VARCHAR), `file_path` (VARCHAR). Insert the three file paths.

3. Read each file back and verify all have 100,000 rows.

## What to Submit

Write your solution in `solutions/ex23.sql`.

## Hints

- After exporting, check file sizes with DuckDB's `SELECT * FROM glob('/tmp/ex23_*.parquet')` to see metadata.
- To compare sizes: `SELECT compression_type, file_path FROM compression_comparison` — then you can observe the file sizes in the filesystem.
