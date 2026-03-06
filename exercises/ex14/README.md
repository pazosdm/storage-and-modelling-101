# Exercise 14 – Many-to-Many with Bridge Table

## Overview

When customers can belong to multiple loyalty programs, and programs can have multiple customers, you have a many-to-many relationship. The standard solution is a **bridge table** (also called a junction or associative table) that sits between the two dimension tables.

## Seed Data

```sql
-- dim_customer_m2m: 3 customers
-- dim_loyalty_program: 3 programs (Gold, Silver, Platinum)
-- fact_sales_m2m: 6 sales
-- raw_memberships: 5 memberships (Alice: Gold+Platinum, Bob: Silver, Carol: Gold+Silver)
```

## Tasks

1. Create `bridge_customer_program` from `raw_memberships`:
   - Columns: `customer_id`, `program_id`, `joined_date`

2. Write a query that returns **total revenue per loyalty program** by allocating each customer's full sales to each of their programs (this intentionally double-counts customers in multiple programs — that's expected with bridge tables).

3. Write a query that returns **customers who belong to more than one program** with their program names listed.

## What to Submit

Write your solution in `solutions/ex14.sql`.

## Hints

- `bridge_customer_program` is a simple `INSERT INTO ... SELECT FROM raw_memberships`.
- For total revenue per program: `JOIN fact_sales_m2m fs ON bcp.customer_id = fs.customer_id JOIN bridge_customer_program bcp ON ... JOIN dim_loyalty_program dlp ON bcp.program_id = dlp.program_id GROUP BY program_name`
- For multi-program customers: use `HAVING COUNT(*) > 1` and `STRING_AGG(program_name, ', ')` for listing.
