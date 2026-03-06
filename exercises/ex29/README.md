# Exercise 29 – Schema Constraints as Contracts

## Overview

DDL constraints are your first line of defense for data quality. By declaring rules at the schema level, you prevent invalid data from ever entering the database. This is the database's **data contract** with the application.

## Tasks

1. Create `fact_orders_contracted` with the following contract enforced via DDL:
   - `order_id` INTEGER, PRIMARY KEY, NOT NULL
   - `customer_id` INTEGER, NOT NULL
   - `product_id` INTEGER, NOT NULL
   - `order_date` DATE, NOT NULL
   - `quantity` INTEGER, NOT NULL, CHECK (quantity > 0)
   - `unit_price` DECIMAL(10,2), NOT NULL, CHECK (unit_price >= 0)
   - `total_amount` DECIMAL(10,2), NOT NULL

2. Insert 5 valid rows.

3. Demonstrate (as comments or in a commented-out block) that the following inserts **fail**:
   - A row with NULL `customer_id`
   - A row with `quantity = 0`
   - A row with negative `unit_price`

## What to Submit

Write your solution in `solutions/ex29.sql`.

## Example table definition

```sql
CREATE TABLE fact_orders_contracted (
    order_id     INTEGER PRIMARY KEY NOT NULL,
    customer_id  INTEGER NOT NULL,
    product_id   INTEGER NOT NULL,
    order_date   DATE NOT NULL,
    quantity     INTEGER NOT NULL CHECK (quantity > 0),
    unit_price   DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_amount DECIMAL(10,2) NOT NULL
);
```

## Hints

- Include the failing inserts as comments so they document the contract:
  ```sql
  -- These would fail (constraint violations):
  -- INSERT INTO fact_orders_contracted VALUES (99, NULL, 1, '2025-01-01', 1, 10.00, 10.00);  -- NULL customer_id
  -- INSERT INTO fact_orders_contracted VALUES (99, 1, 1, '2025-01-01', 0, 10.00, 0.00);       -- quantity=0
  -- INSERT INTO fact_orders_contracted VALUES (99, 1, 1, '2025-01-01', 1, -5.00, -5.00);      -- negative price
  ```
