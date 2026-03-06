# Exercise 20 – Flatten Nested Arrays

## Overview

Invoices often arrive with line items embedded as JSON arrays. You need to "explode" (unnest) these arrays into a relational table where each row represents one line item. This is a common ELT pattern in modern data pipelines.

## Seed Data

```sql
-- raw_invoices: 3 invoices with a JSON line_items array
-- INV-001: 2 items (Laptop + Mouse)
-- INV-002: 1 item (Monitor)
-- INV-003: 3 items (Keyboard + USB Hub + Mouse)
```

## Tasks

1. Create `fact_invoice_lines` by flattening the JSON arrays:
   - Columns: `invoice_id`, `customer_id`, `invoice_date`, `product`, `quantity`, `unit_price`, `line_total` (qty * price)

2. Use `UNNEST` to flatten.

3. Write a query that returns total revenue per customer (just write it in your solution).

## What to Submit

Write your solution in `solutions/ex20.sql`.

## Hints

- DuckDB can unnest a JSON array using: `UNNEST(CAST(line_items AS JSON[]))` or `json_array_elements`
- After unnesting, use `json_extract_string(elem, '$.product')` and `CAST(json_extract(elem, '$.qty') AS INTEGER)` to extract fields from each element.
- Example unnest pattern:
  ```sql
  SELECT i.invoice_id, i.customer_id, i.invoice_date,
         json_extract_string(elem, '$.product') AS product,
         CAST(json_extract(elem, '$.qty') AS INTEGER) AS quantity,
         CAST(json_extract(elem, '$.price') AS DECIMAL(10,2)) AS unit_price
  FROM raw_invoices i, UNNEST(CAST(i.line_items AS JSON[])) t(elem)
  ```
