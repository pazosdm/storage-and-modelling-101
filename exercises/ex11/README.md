# Exercise 11 – Define Grain and Design Fact Tables

## Overview

Practice defining the **grain** of a fact table — the most atomic level of detail the table represents. You'll build two separate fact tables with different grains from two raw data sources.

## Seed Data

```sql
-- raw_web_sessions: 5 sessions (S1-S5) with start/end timestamps, channel, device, and conversion flag
-- raw_orders: 3 orders with user, channel, country, and total
```

## Tasks

1. Create `dim_user` (user_id) — just the key, no other attributes in seed
2. Create `dim_channel` (channel_id surrogate, channel_name)
3. Create `dim_date` with grain = one day, covering 2025-01-10 to 2025-01-12: date_key, year, month, day
4. Create `fact_sessions` with grain = one session:
   - session_id, user_id, date_key, channel_id, device, page_views, session_duration_minutes, converted
5. Create `fact_orders` with grain = one order:
   - order_id, user_id, date_key, channel_id, country, order_total
6. Write a query that computes conversion rate per channel (no need to save it as a view)

## What to Submit

Write your solution in `solutions/ex11.sql`.

## Hints

- `session_duration_minutes = DATE_DIFF('minute', session_start, session_end)`
- For `dim_channel`, assign surrogate IDs using `ROW_NUMBER()` from distinct channels in `raw_web_sessions`.
- Join `fact_sessions` to `dim_channel` to get `channel_id` by matching on `channel_name`.
- Conversion rate query: `SUM(converted::INT) / COUNT(*) AS conversion_rate` grouped by `channel_name`.
