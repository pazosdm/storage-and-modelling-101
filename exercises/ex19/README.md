# Exercise 19 – Hybrid Model: Extract JSON Fields

## Overview

Raw event data often arrives as JSON blobs. A **hybrid model** extracts the most commonly queried fields into typed columns (for fast filtering) while keeping the remaining fields in a JSON column (for flexibility). This avoids the performance cost of parsing JSON in every query.

## Seed Data

```sql
-- raw_events: 5 events with a JSON `properties` column
-- Each event has url, browser, device in JSON; some have campaign_id, element, order_id
```

## Tasks

1. Create `fact_web_events` with:
   - Promoted columns: `event_id`, `event_ts`, `user_id`, `event_type`, `url`, `browser`, `device`
   - Remaining JSON in a `details` column (JSON type) — containing only fields NOT already extracted

2. Populate from `raw_events`.

3. Write a query that counts events by `device` type (just write it in your solution).

4. Write a query that extracts `campaign_id` from the `details` column for events that have it.

## What to Submit

Write your solution in `solutions/ex19.sql`.

## Hints

- `json_extract_string(properties, '$.url')` extracts the url field as a string.
- For the `details` column, use DuckDB's JSON functions to reconstruct the remaining fields:
  - You can create a new JSON object with only the extra fields, e.g., for E1: `{"campaign_id":"camp1"}`
  - Or store `properties` as-is in `details` (simpler approach, though not strictly "only remaining fields")
- `json_extract_string(details, '$.campaign_id') IS NOT NULL` filters events with campaign_id.
