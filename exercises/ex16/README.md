# Exercise 16 – Data Vault: Hub, Link, Satellite

## Overview

Data Vault is a modeling methodology designed for enterprise data warehouses. Its three core components are:
- **Hub**: stores unique business keys
- **Link**: stores relationships between hubs
- **Satellite**: stores descriptive attributes with history

In this exercise, you'll load data from two source systems (CRM and ECOM) into a Data Vault structure.

## Seed Data

```sql
-- src_crm_customers: 2 CRM customers (CRM-001: Alice, CRM-002: Bob)
-- src_ecom_customers: 3 ECOM customers (ECOM-A1: Alice M., ECOM-B1: Robert, ECOM-C1: Carol)
-- Note: Alice and Bob appear in both systems under different IDs
```

## Tasks

1. Create `h_customer` (Hub):
   - `customer_hash_key` (MD5 of business key)
   - `customer_bk` (original source business key)
   - `load_ts`, `record_source`

2. Create `l_customer_source` (Link):
   - `link_hash_key`, `customer_hash_key` (FK to hub), `source_customer_id`, `source_system`, `load_ts`

3. Create `s_customer_details` (Satellite):
   - `customer_hash_key`, `name`, `email`, `city`, `load_ts`, `record_source`

4. Populate all three from both source tables (treat each source record as a unique business key).

## What to Submit

Write your solution in `solutions/ex16.sql`.

## Hints

- `MD5(customer_id)` in DuckDB returns a 32-character hex string.
- Combine both sources with `UNION ALL` before inserting.
- The hub should have one row per unique `customer_id` (business key) — since we treat each source ID as unique, there will be 5 rows.
- For `link_hash_key`, you can use `MD5(customer_id || source_system)` to create a unique link key.
