# Exercise 26 – ACID Transactions

## Overview

ACID properties (Atomicity, Consistency, Isolation, Durability) guarantee database reliability. This exercise focuses on **Atomicity**: either all changes in a transaction succeed, or none do. You'll use `BEGIN`/`COMMIT`/`ROLLBACK` to implement atomic money transfers.

## Seed Data

```sql
CREATE TABLE account_balances (account_id INTEGER PRIMARY KEY, balance DECIMAL(10,2));
INSERT INTO account_balances VALUES (1, 1000.00), (2, 500.00), (3, 750.00);
```

## Tasks

1. Write a **successful** transaction that transfers 200.00 from account 1 to account 2:
   ```sql
   BEGIN;
   UPDATE account_balances SET balance = balance - 200 WHERE account_id = 1;
   UPDATE account_balances SET balance = balance + 200 WHERE account_id = 2;
   COMMIT;
   ```

2. Write a **rolled-back** transaction that attempts to withdraw 2000.00 from account 3 (more than the balance):
   ```sql
   BEGIN;
   UPDATE account_balances SET balance = balance - 2000 WHERE account_id = 3;
   -- Business rule check: balance would go negative, so rollback
   ROLLBACK;
   ```

3. After both transactions, verify final balances: account 1 = 800, account 2 = 700, account 3 = 750.

## What to Submit

Write your solution in `solutions/ex26.sql`.

## Hints

- Both UPDATE statements inside a transaction are atomic — if one fails, both are rolled back automatically.
- The ROLLBACK undoes all changes in the current transaction.
- DuckDB supports `BEGIN`/`COMMIT`/`ROLLBACK` for explicit transaction control.
