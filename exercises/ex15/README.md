# Exercise 15 – Factless Fact Table and Rolling Metrics

## Overview

A **factless fact table** records events without numeric measures. It answers "did X happen?" rather than "how much of X happened?". Login events are a classic example — what matters is whether a user logged in, not a measurable amount.

## Seed Data

```sql
-- dim_user_login: 4 users (U1-U4), segment: Free/Premium
-- dim_device: 3 device types
-- raw_logins: 16 login events from Jan 10-16
```

## Tasks

1. Create `fact_logins` (factless fact table):
   - Columns: `login_date` (DATE), `user_id`, `device_id`, `feature_used`
   - Populate from `raw_logins` (extract date from `login_ts`)

2. Write a query for **Daily Active Users (DAU)**: date, distinct user count

3. Write a query for **7-day rolling active users**: for each date, count distinct users who logged in that day or the previous 6 days

4. Write a query for **feature adoption by segment**: segment, feature_used, distinct user count

## What to Submit

Write your solution in `solutions/ex15.sql`.

## Hints

- `login_date = CAST(login_ts AS DATE)` extracts the date.
- For DAU: `SELECT login_date, COUNT(DISTINCT user_id) AS dau FROM fact_logins GROUP BY login_date ORDER BY login_date`
- For rolling 7-day: self-join on `f2.login_date BETWEEN f1.login_date - INTERVAL 6 DAYS AND f1.login_date`, or use a window with `RANGE BETWEEN`
- For feature adoption by segment: join `fact_logins` to `dim_user_login` on `user_id`.
