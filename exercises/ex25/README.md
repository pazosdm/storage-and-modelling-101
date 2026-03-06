# Exercise 25 – Simulate CDC with Incremental Loads

## Overview

Change Data Capture (CDC) captures INSERT, UPDATE, and DELETE operations from a source system. In this exercise, you apply a CDC log to a warehouse table and record an audit trail of what was changed.

## Seed Data

```sql
-- warehouse_products: 3 products in current warehouse state
-- cdc_product_changes: 3 CDC records — UPDATE product 2, INSERT product 4, DELETE product 3
```

## Tasks

1. Apply the CDC changes to `warehouse_products`:
   - **UPDATE** product 2 with new name and price
   - **INSERT** product 4
   - **DELETE** product 3

2. Create a `cdc_audit_log` table with: `product_id`, `change_type`, `applied_at` (use `CURRENT_TIMESTAMP`)

3. Populate `cdc_audit_log` as you apply each change.

## What to Submit

Write your solution in `solutions/ex25.sql`.

## Hints

- Process each change_type separately:
  ```sql
  -- UPDATE
  UPDATE warehouse_products SET product_name = c.product_name, price = c.price, last_updated = c.change_ts::DATE
  FROM cdc_product_changes c WHERE warehouse_products.product_id = c.product_id AND c.change_type = 'UPDATE';

  -- INSERT
  INSERT INTO warehouse_products SELECT product_id, product_name, category, price, change_ts::DATE
  FROM cdc_product_changes WHERE change_type = 'INSERT';

  -- DELETE
  DELETE FROM warehouse_products WHERE product_id IN (SELECT product_id FROM cdc_product_changes WHERE change_type = 'DELETE');
  ```
- Create `cdc_audit_log` before applying changes, then insert audit records.
