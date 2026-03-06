# Exercise 03 – Normalize Reference Data with Deduplication

## Overview

The `raw_products` table has category data embedded directly, with some **typos** in category names. You need to extract and normalize the category reference data, correcting the typos in the process.

## Seed Data

```sql
CREATE TABLE raw_products (
    product_id       INTEGER,
    product_name     VARCHAR,
    category_name    VARCHAR,   -- contains typos: 'Furnitur', 'Electronicss'
    category_group   VARCHAR,
    tax_rate         DECIMAL(5,2),
    unit_of_measure  VARCHAR
);
-- 7 products: some with correct categories, some with typos
```

Known typos to fix:
- `'Furnitur'` → `'Furniture'`
- `'Electronicss'` → `'Electronics'`

## Tasks

1. Create a `categories` table with:
   - A surrogate `category_id` (you can use `ROW_NUMBER()` or a sequence)
   - Deduplicated `category_name` (after fixing typos)
   - `category_group`

2. Create a `products` table with:
   - `product_id`, `product_name`, `category_id` (FK to categories), `tax_rate`, `unit_of_measure`

3. Populate both tables from `raw_products`, mapping the typo categories to their correct counterparts.

## What to Submit

Write your solution in `solutions/ex03.sql`.

## Hints

- Use `REPLACE(category_name, 'Furnitur', 'Furniture')` or `CASE WHEN` to fix typos before inserting into `categories`.
- After fixing, there should be exactly 2 distinct categories.
- When inserting into `products`, join back to `categories` to get the correct `category_id`.
