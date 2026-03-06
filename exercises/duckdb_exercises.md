## Section 1: Normalization (4 exercises)

### Exercise 1 – Normalize a Wide Table to 3NF

**Seed:**

```sql
CREATE TABLE stg_orders (
    order_id         INTEGER,
    order_date       DATE,
    customer_id      INTEGER,
    customer_name    VARCHAR,
    customer_email   VARCHAR,
    customer_city    VARCHAR,
    product_id       INTEGER,
    product_name     VARCHAR,
    product_category VARCHAR,
    unit_price       DECIMAL(10,2),
    quantity         INTEGER,
    store_id         INTEGER,
    store_name       VARCHAR,
    store_city       VARCHAR
);

INSERT INTO stg_orders VALUES
(1, '2025-01-15', 101, 'Alice', 'alice@mail.com', 'São Paulo', 201, 'Widget A', 'Gadgets', 29.99, 2, 301, 'Store Central', 'São Paulo'),
(2, '2025-01-16', 102, 'Bob', 'bob@mail.com', 'Rio de Janeiro', 202, 'Widget B', 'Tools', 49.99, 1, 302, 'Store Norte', 'Brasília'),
(3, '2025-01-16', 101, 'Alice', 'alice@mail.com', 'São Paulo', 203, 'Widget C', 'Gadgets', 19.99, 5, 301, 'Store Central', 'São Paulo'),
(4, '2025-01-17', 103, 'Carol', 'carol@mail.com', 'Belo Horizonte', 201, 'Widget A', 'Gadgets', 29.99, 3, 303, 'Store Sul', 'Curitiba'),
(5, '2025-01-18', 102, 'Bob', 'bob@mail.com', 'Rio de Janeiro', 204, 'Widget D', 'Tools', 99.99, 1, 301, 'Store Central', 'São Paulo'),
(6, '2025-01-19', 104, 'Diana', 'diana@mail.com', 'Curitiba', 202, 'Widget B', 'Tools', 49.99, 2, 302, 'Store Norte', 'Brasília');
```

**Tasks:**

1. Create the following normalized tables from `stg_orders`:
   - `customers` (customer_id PK, customer_name, customer_email, customer_city)
   - `products` (product_id PK, product_name, product_category, unit_price)
   - `stores` (store_id PK, store_name, store_city)
   - `orders` (order_id PK, order_date, customer_id FK, product_id FK, store_id FK, quantity)
2. Populate each table using `INSERT INTO ... SELECT DISTINCT ...` from `stg_orders`.
3. Ensure no duplicate rows exist in any dimension table.

**Grading:**

```sql
-- G1: All four tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'main' AND table_name IN ('customers','products','stores','orders')
ORDER BY table_name;
-- Expected: customers, orders, products, stores (4 rows)

-- G2: Correct row counts
SELECT 'customers' AS t, COUNT(*) AS n FROM customers UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'stores', COUNT(*) FROM stores UNION ALL
SELECT 'orders', COUNT(*) FROM orders
ORDER BY t;
-- Expected: customers=4, orders=6, products=4, stores=3

-- G3: No duplicates in customers
SELECT COUNT(*) = COUNT(DISTINCT customer_id) AS no_dupes FROM customers;
-- Expected: true

-- G4: Referential check - all customer_ids in orders exist in customers
SELECT COUNT(*) FROM orders o WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id);
-- Expected: 0
```

---

### Exercise 2 – Identify and Fix Anomalies

**Seed:** Same `stg_orders` from Exercise 1, plus:

```sql
-- Simulate anomaly: Alice changed her email
INSERT INTO stg_orders VALUES
(7, '2025-01-20', 101, 'Alice', 'alice.new@mail.com', 'São Paulo', 201, 'Widget A', 'Gadgets', 29.99, 1, 301, 'Store Central', 'São Paulo');
```

**Tasks:**

1. Create normalized tables `customers`, `products`, `stores`, and `orders` with proper **PRIMARY KEY** and **NOT NULL** constraints.
2. For customers with multiple emails (like Alice), keep only the **most recent** email (based on the latest order_date).
3. Populate all tables, ensuring the constraints are satisfied.

**Grading:**

```sql
-- G1: customers table has exactly 4 rows (no duplicate customer_ids)
SELECT COUNT(*) FROM customers;
-- Expected: 4

-- G2: Alice has only the new email
SELECT customer_email FROM customers WHERE customer_id = 101;
-- Expected: 'alice.new@mail.com'

-- G3: orders table has 7 rows
SELECT COUNT(*) FROM orders;
-- Expected: 7

-- G4: Primary key constraint exists on customers
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'customers' AND constraint_type = 'PRIMARY KEY';
-- Expected: 1
```

---

### Exercise 3 – Normalize Reference Data with Deduplication

**Seed:**

```sql
CREATE TABLE raw_products (
    product_id       INTEGER,
    product_name     VARCHAR,
    category_name    VARCHAR,
    category_group   VARCHAR,
    tax_rate         DECIMAL(5,2),
    unit_of_measure  VARCHAR
);

INSERT INTO raw_products VALUES
(1, 'Laptop Pro', 'Electronics', 'Tech', 15.00, 'unit'),
(2, 'Phone X', 'Electronics', 'Tech', 15.00, 'unit'),
(3, 'Desk Chair', 'Furniture', 'Office', 10.00, 'unit'),
(4, 'Standing Desk', 'Furnitur', 'Office', 10.00, 'unit'),   -- typo in category
(5, 'USB Cable', 'Electronicss', 'Tech', 15.00, 'unit'),     -- typo in category
(6, 'Monitor 27"', 'Electronics', 'Tech', 15.00, 'unit'),
(7, 'Bookshelf', 'Furniture', 'Office', 10.00, 'unit');
```

**Tasks:**

1. Create a `categories` table with a surrogate `category_id`, deduplicated `category_name`, and `category_group`. Fix the known typos: map 'Furnitur' → 'Furniture' and 'Electronicss' → 'Electronics'.
2. Create a `products` table with `product_id`, `product_name`, `category_id` (FK), `tax_rate`, and `unit_of_measure`.
3. Populate both tables from `raw_products`.

**Grading:**

```sql
-- G1: categories has exactly 2 rows
SELECT COUNT(*) FROM categories;
-- Expected: 2

-- G2: No typos in categories
SELECT COUNT(*) FROM categories WHERE category_name NOT IN ('Electronics', 'Furniture');
-- Expected: 0

-- G3: products has 7 rows
SELECT COUNT(*) FROM products;
-- Expected: 7

-- G4: All products link to a valid category
SELECT COUNT(*) FROM products p WHERE NOT EXISTS (SELECT 1 FROM categories c WHERE c.category_id = p.category_id);
-- Expected: 0

-- G5: Product 4 (Standing Desk) maps to Furniture
SELECT c.category_name FROM products p JOIN categories c ON p.category_id = c.category_id WHERE p.product_id = 4;
-- Expected: 'Furniture'
```

---

### Exercise 4 – Normalization vs Query Complexity

**Seed:**

```sql
CREATE TABLE dim_customer (customer_id INTEGER PRIMARY KEY, customer_name VARCHAR, city_id INTEGER);
CREATE TABLE dim_city (city_id INTEGER PRIMARY KEY, city_name VARCHAR, country_id INTEGER);
CREATE TABLE dim_country (country_id INTEGER PRIMARY KEY, country_name VARCHAR, region VARCHAR);
CREATE TABLE fact_sales (order_id INTEGER PRIMARY KEY, customer_id INTEGER, order_date DATE, amount DECIMAL(10,2));

INSERT INTO dim_country VALUES (1, 'Brazil', 'LATAM'), (2, 'Argentina', 'LATAM'), (3, 'USA', 'NA');
INSERT INTO dim_city VALUES (10, 'São Paulo', 1), (11, 'Buenos Aires', 2), (12, 'New York', 3), (13, 'Rio de Janeiro', 1);
INSERT INTO dim_customer VALUES (101, 'Alice', 10), (102, 'Bob', 13), (103, 'Carlos', 11), (104, 'Diana', 12), (105, 'Eve', 10);
INSERT INTO fact_sales VALUES
(1, 101, '2025-01-10', 500.00), (2, 101, '2025-01-15', 300.00),
(3, 102, '2025-01-12', 700.00), (4, 103, '2025-01-14', 200.00),
(5, 104, '2025-01-16', 1500.00), (6, 105, '2025-01-17', 400.00),
(7, 102, '2025-01-20', 250.00), (8, 104, '2025-01-22', 800.00),
(9, 103, '2025-01-25', 350.00), (10, 101, '2025-01-28', 600.00);
```

**Tasks:**

1. Create a view `v_sales_by_country` that returns `country_name` and `total_sales` (sum of amount), ordered by `total_sales` descending.
2. Create a view `v_top_customers_by_country` that returns `country_name`, `customer_name`, `total_sales`, and `rank_in_country` (rank within each country by sales, descending). Use `RANK()`.
3. Create a denormalized table `dim_customer_flat` that flattens customer → city → country into a single table (customer_id, customer_name, city_name, country_name, region). Populate it.

**Grading:**

```sql
-- G1: v_sales_by_country returns 3 countries
SELECT COUNT(*) FROM v_sales_by_country;
-- Expected: 3

-- G2: USA has the highest total sales
SELECT country_name FROM v_sales_by_country LIMIT 1;
-- Expected: 'USA'

-- G3: v_top_customers_by_country - Alice is rank 1 in Brazil
SELECT rank_in_country FROM v_top_customers_by_country WHERE customer_name = 'Alice';
-- Expected: 1

-- G4: dim_customer_flat has 5 rows with all columns populated
SELECT COUNT(*) FROM dim_customer_flat WHERE country_name IS NOT NULL;
-- Expected: 5
```

---

## Section 2: Entity-Relationship Modeling (2 exercises)

### Exercise 5 – ER Design for a University System

**Scenario:** Design a database for a university course enrollment system.

**Requirements:**
- Students have a student_id, name, and enrollment_year.
- Courses have a course_id, course_name, and credits.
- Professors have a professor_id and name.
- Each course is taught by exactly one professor.
- Students can enroll in many courses; each course can have many students.
- Each enrollment has a grade (nullable, assigned later).

**Tasks:**

1. Create tables: `students`, `professors`, `courses`, `enrollments`.
2. Define appropriate PRIMARY KEY, FOREIGN KEY, and NOT NULL constraints.
3. Insert the following seed data and verify your constraints work:
   - 3 students, 2 professors, 3 courses, 5 enrollments.
4. Write a query that returns each student's name and total enrolled credits.

**Grading:**

```sql
-- G1: All four tables exist
SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('students','professors','courses','enrollments');
-- Expected: 4

-- G2: courses has foreign key to professors
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'courses' AND constraint_type = 'FOREIGN KEY';
-- Expected: 1

-- G3: enrollments has foreign keys to both students and courses
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'enrollments' AND constraint_type = 'FOREIGN KEY';
-- Expected: 2

-- G4: Seed data present
SELECT COUNT(*) FROM students;
-- Expected: 3
SELECT COUNT(*) FROM enrollments;
-- Expected: 5
```

---

### Exercise 6 – Resolve Many-to-Many Relationships

**Seed:**

```sql
CREATE TABLE raw_book_authors (
    book_id     INTEGER,
    book_title  VARCHAR,
    author_name VARCHAR,
    genre       VARCHAR,
    pub_year    INTEGER
);

INSERT INTO raw_book_authors VALUES
(1, 'Data Warehouse Toolkit', 'Ralph Kimball', 'Technical', 2013),
(1, 'Data Warehouse Toolkit', 'Margy Ross', 'Technical', 2013),
(2, 'Building the DW', 'Ralph Kimball', 'Technical', 2011),
(3, 'Designing Data Apps', 'Martin Kleppmann', 'Technical', 2017),
(4, 'The Data Model Resource Book', 'Len Silverston', 'Technical', 2001),
(4, 'The Data Model Resource Book', 'Paul Agnew', 'Technical', 2001);
```

**Tasks:**

1. Create normalized tables: `authors` (author_id, author_name), `books` (book_id, book_title, genre, pub_year), and `book_authors` (book_id, author_id) as a junction table.
2. Generate `author_id` as a surrogate key using `ROW_NUMBER()`.
3. Populate all three tables from `raw_book_authors`.
4. Write a query that returns each author and the number of books they co-authored.

**Grading:**

```sql
-- G1: authors has 4 distinct authors
SELECT COUNT(*) FROM authors;
-- Expected: 4

-- G2: books has 4 books
SELECT COUNT(*) FROM books;
-- Expected: 4

-- G3: book_authors has 6 relationships
SELECT COUNT(*) FROM book_authors;
-- Expected: 6

-- G4: Ralph Kimball has 2 books
SELECT COUNT(*) FROM book_authors ba JOIN authors a ON ba.author_id = a.author_id WHERE a.author_name = 'Ralph Kimball';
-- Expected: 2
```

---

## Section 3: Denormalization & Star Schema (4 exercises)

### Exercise 7 – Build a Star Schema from 3NF

**Seed:**

```sql
CREATE TABLE oltp_customers (customer_id INTEGER, name VARCHAR, email VARCHAR, city VARCHAR, state VARCHAR, country VARCHAR);
CREATE TABLE oltp_products (product_id INTEGER, product_name VARCHAR, category VARCHAR, brand VARCHAR, unit_price DECIMAL(10,2));
CREATE TABLE oltp_orders (order_id INTEGER, customer_id INTEGER, order_date DATE, status VARCHAR);
CREATE TABLE oltp_order_items (order_id INTEGER, product_id INTEGER, quantity INTEGER, unit_price DECIMAL(10,2));

INSERT INTO oltp_customers VALUES
(1, 'Alice', 'alice@mail.com', 'São Paulo', 'SP', 'Brazil'),
(2, 'Bob', 'bob@mail.com', 'Buenos Aires', 'BA', 'Argentina'),
(3, 'Carol', 'carol@mail.com', 'New York', 'NY', 'USA');

INSERT INTO oltp_products VALUES
(101, 'Laptop', 'Electronics', 'TechCo', 999.99),
(102, 'Mouse', 'Peripherals', 'ClickCo', 29.99),
(103, 'Monitor', 'Electronics', 'ViewCo', 499.99);

INSERT INTO oltp_orders VALUES
(1001, 1, '2025-01-10', 'completed'), (1002, 2, '2025-01-12', 'completed'),
(1003, 1, '2025-01-15', 'completed'), (1004, 3, '2025-02-01', 'completed');

INSERT INTO oltp_order_items VALUES
(1001, 101, 1, 999.99), (1001, 102, 2, 29.99),
(1002, 103, 1, 499.99), (1003, 102, 5, 29.99),
(1004, 101, 1, 999.99), (1004, 103, 2, 499.99);
```

**Tasks:**

1. Create a `dim_customer` table (customer_id, name, email, city, state, country).
2. Create a `dim_product` table (product_id, product_name, category, brand).
3. Create a `dim_date` table with at least: date_key (DATE), year, month, day, day_of_week. Populate it for January and February 2025.
4. Create a `fact_sales` table with grain = one row per order line item. Include: order_id, customer_id, product_id, order_date, quantity, unit_price, total_amount (quantity * unit_price).
5. Populate `fact_sales` from the OLTP tables.

**Grading:**

```sql
-- G1: fact_sales has 6 rows (one per order item)
SELECT COUNT(*) FROM fact_sales;
-- Expected: 6

-- G2: Total revenue matches
SELECT SUM(total_amount) FROM fact_sales;
-- Expected: 3089.90

-- G3: dim_date covers Jan-Feb 2025
SELECT COUNT(*) FROM dim_date WHERE date_key BETWEEN '2025-01-01' AND '2025-02-28';
-- Expected: 59

-- G4: All fact_sales dates exist in dim_date
SELECT COUNT(*) FROM fact_sales f WHERE NOT EXISTS (SELECT 1 FROM dim_date d WHERE d.date_key = f.order_date);
-- Expected: 0
```

---

### Exercise 8 – Customer 360 Denormalized Table

**Seed:** Uses the star schema tables created in Exercise 7 (run Exercise 7 seed + solution first).

If running standalone, use this combined seed that creates the star schema directly:

```sql
CREATE TABLE dim_customer AS SELECT * FROM (VALUES
    (1, 'Alice', 'alice@mail.com', 'São Paulo', 'SP', 'Brazil'),
    (2, 'Bob', 'bob@mail.com', 'Buenos Aires', 'BA', 'Argentina'),
    (3, 'Carol', 'carol@mail.com', 'New York', 'NY', 'USA')
) t(customer_id, name, email, city, state, country);

CREATE TABLE dim_product AS SELECT * FROM (VALUES
    (101, 'Laptop', 'Electronics', 'TechCo'),
    (102, 'Mouse', 'Peripherals', 'ClickCo'),
    (103, 'Monitor', 'Electronics', 'ViewCo')
) t(product_id, product_name, category, brand);

CREATE TABLE fact_sales AS SELECT * FROM (VALUES
    (1001, 1, 101, '2025-01-10'::DATE, 1, 999.99, 999.99),
    (1001, 1, 102, '2025-01-10'::DATE, 2, 29.99, 59.98),
    (1002, 2, 103, '2025-01-12'::DATE, 1, 499.99, 499.99),
    (1003, 1, 102, '2025-01-15'::DATE, 5, 29.99, 149.95),
    (1004, 3, 101, '2025-02-01'::DATE, 1, 999.99, 999.99),
    (1004, 3, 103, '2025-02-01'::DATE, 2, 499.99, 999.98)
) t(order_id, customer_id, product_id, order_date, quantity, unit_price, total_amount);
```

**Tasks:**

1. Create a `customer_360` table with:
   - customer_id, name, city, country
   - total_lifetime_sales (sum of total_amount)
   - total_orders (count of distinct order_ids)
   - last_order_date
   - favorite_category (category with highest spend)
2. Populate it using a single query from `fact_sales`, `dim_customer`, and `dim_product`.

**Grading:**

```sql
-- G1: 3 rows
SELECT COUNT(*) FROM customer_360;
-- Expected: 3

-- G2: Alice lifetime sales
SELECT total_lifetime_sales FROM customer_360 WHERE customer_id = 1;
-- Expected: 1209.92

-- G3: Alice total orders (2 distinct orders: 1001, 1003)
SELECT total_orders FROM customer_360 WHERE customer_id = 1;
-- Expected: 2

-- G4: Carol's favorite category
SELECT favorite_category FROM customer_360 WHERE customer_id = 3;
-- Expected: 'Electronics'
```

---

### Exercise 9 – One Big Table for BI

**Seed:** Same star schema from Exercise 8.

**Tasks:**

1. Create a `sales_obt` table that pre-joins all dimensions into a single flat table. Include: order_id, order_date, customer_name, customer_city, customer_country, product_name, product_category, product_brand, quantity, unit_price, total_amount.
2. Populate it from `fact_sales`, `dim_customer`, and `dim_product`.
3. Create a view `v_monthly_category_revenue` on top of `sales_obt` that returns year, month, product_category, and total_revenue. Order by year, month, category.

**Grading:**

```sql
-- G1: sales_obt has 6 rows
SELECT COUNT(*) FROM sales_obt;
-- Expected: 6

-- G2: No NULLs in customer_name or product_name
SELECT COUNT(*) FROM sales_obt WHERE customer_name IS NULL OR product_name IS NULL;
-- Expected: 0

-- G3: Monthly category revenue view - Electronics in January
SELECT total_revenue FROM v_monthly_category_revenue WHERE month = 1 AND product_category = 'Electronics';
-- Expected: 999.99

-- G4: Total rows in view
SELECT COUNT(*) FROM v_monthly_category_revenue;
-- Expected: 3
```

---

### Exercise 10 – Views vs Precomputed Summary Tables

**Seed:** Same star schema from Exercise 8.

**Tasks:**

1. Create a **view** `v_daily_revenue` that computes daily total revenue from `fact_sales`.
2. Create a **table** `summary_daily_revenue` with the same content (precomputed via CTAS).
3. Create a **table** `summary_monthly_store_revenue` that aggregates revenue by month and customer country from fact_sales + dim_customer. Include: year, month, country, total_revenue, total_orders.

**Grading:**

```sql
-- G1: View exists
SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'v_daily_revenue' AND table_type = 'VIEW';
-- Expected: 1

-- G2: View returns correct data
SELECT total_revenue FROM v_daily_revenue WHERE order_date = '2025-01-10';
-- Expected: 1059.97

-- G3: Summary table matches view
SELECT COUNT(*) FROM summary_daily_revenue;
-- Expected: 3 (3 distinct dates)

-- G4: Monthly store revenue
SELECT total_revenue FROM summary_monthly_store_revenue WHERE month = 1 AND country = 'Brazil';
-- Expected: 1209.92
```

---

## Section 4: Dimensional Modeling (5 exercises)

### Exercise 11 – Define Grain and Design Fact Tables

**Seed:**

```sql
CREATE TABLE raw_web_sessions (
    session_id    VARCHAR,
    user_id       VARCHAR,
    session_start TIMESTAMP,
    session_end   TIMESTAMP,
    channel       VARCHAR,
    device        VARCHAR,
    page_views    INTEGER,
    converted     BOOLEAN
);

CREATE TABLE raw_orders (
    order_id   VARCHAR,
    user_id    VARCHAR,
    order_ts   TIMESTAMP,
    channel    VARCHAR,
    country    VARCHAR,
    order_total DECIMAL(10,2)
);

INSERT INTO raw_web_sessions VALUES
('S1', 'U1', '2025-01-10 09:00', '2025-01-10 09:15', 'organic', 'mobile', 5, true),
('S2', 'U2', '2025-01-10 10:00', '2025-01-10 10:05', 'paid', 'desktop', 3, false),
('S3', 'U1', '2025-01-11 14:00', '2025-01-11 14:30', 'organic', 'mobile', 8, true),
('S4', 'U3', '2025-01-11 16:00', '2025-01-11 16:10', 'email', 'mobile', 2, false),
('S5', 'U2', '2025-01-12 08:00', '2025-01-12 08:20', 'paid', 'desktop', 6, true);

INSERT INTO raw_orders VALUES
('O1', 'U1', '2025-01-10 09:12', 'organic', 'Brazil', 150.00),
('O2', 'U1', '2025-01-11 14:25', 'organic', 'Brazil', 200.00),
('O3', 'U2', '2025-01-12 08:18', 'paid', 'USA', 75.00);
```

**Tasks:**

1. Create `dim_user` (user_id, — no other attributes in seed, just the key).
2. Create `dim_channel` (channel_id surrogate, channel_name).
3. Create `dim_date` with grain = one day, covering 2025-01-10 to 2025-01-12. Include: date_key, year, month, day.
4. Create `fact_sessions` with grain = one session. Include: session_id, user_id, date_key, channel_id, device, page_views, session_duration_minutes, converted.
5. Create `fact_orders` with grain = one order. Include: order_id, user_id, date_key, channel_id, country, order_total.
6. Write a query that computes **conversion rate per channel** (sessions that converted / total sessions).

**Grading:**

```sql
-- G1: fact_sessions has 5 rows
SELECT COUNT(*) FROM fact_sessions;
-- Expected: 5

-- G2: fact_orders has 3 rows
SELECT COUNT(*) FROM fact_orders;
-- Expected: 3

-- G3: Session S1 duration is 15 minutes
SELECT session_duration_minutes FROM fact_sessions WHERE session_id = 'S1';
-- Expected: 15

-- G4: Organic conversion rate = 2/2 = 1.0
-- (Both organic sessions converted)
-- Grader can run the student's conversion rate query and validate organic = 1.0
```

---

### Exercise 12 – SCD Type 1 (Overwrite)

**Seed:**

```sql
CREATE TABLE dim_product (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR,
    category     VARCHAR,
    brand        VARCHAR,
    updated_at   DATE
);

INSERT INTO dim_product VALUES
(1, 'Laptop Pro', 'Electronics', 'TechCo', '2025-01-01'),
(2, 'Wireless Mouse', 'Peripherals', 'ClickCo', '2025-01-01'),
(3, 'USB-C Hub', 'Accessories', 'PortCo', '2025-01-01');

CREATE TABLE stg_product_updates (
    product_id   INTEGER,
    product_name VARCHAR,
    category     VARCHAR,
    brand        VARCHAR,
    load_date    DATE
);

INSERT INTO stg_product_updates VALUES
(2, 'Wireless Mouse v2', 'Peripherals', 'ClickCo', '2025-02-01'),  -- name changed
(3, 'USB-C Hub', 'Connectivity', 'PortCo', '2025-02-01'),          -- category changed
(4, 'Webcam HD', 'Peripherals', 'ViewCo', '2025-02-01');           -- new product
```

**Tasks:**

1. Write SQL that applies SCD Type 1 logic to `dim_product`:
   - **Update** existing products where attributes changed (overwrite with new values, update `updated_at`).
   - **Insert** new products that don't exist yet.
2. After execution, `dim_product` should reflect the latest state with no history preserved.

**Grading:**

```sql
-- G1: 4 products total (3 existing + 1 new)
SELECT COUNT(*) FROM dim_product;
-- Expected: 4

-- G2: Product 2 name updated
SELECT product_name FROM dim_product WHERE product_id = 2;
-- Expected: 'Wireless Mouse v2'

-- G3: Product 3 category updated
SELECT category FROM dim_product WHERE product_id = 3;
-- Expected: 'Connectivity'

-- G4: Product 4 inserted
SELECT product_name FROM dim_product WHERE product_id = 4;
-- Expected: 'Webcam HD'

-- G5: Product 1 unchanged
SELECT updated_at FROM dim_product WHERE product_id = 1;
-- Expected: '2025-01-01'
```

---

### Exercise 13 – SCD Type 2 (Preserve History)

**Seed:**

```sql
CREATE TABLE dim_customer_scd2 (
    customer_sk  INTEGER,
    customer_id  VARCHAR,
    name         VARCHAR,
    email        VARCHAR,
    city         VARCHAR,
    segment      VARCHAR,
    valid_from   DATE,
    valid_to     DATE,
    is_current   BOOLEAN
);

INSERT INTO dim_customer_scd2 VALUES
(1, 'C001', 'Alice', 'alice@mail.com', 'São Paulo', 'Regular', '2025-01-01', '9999-12-31', true),
(2, 'C002', 'Bob', 'bob@mail.com', 'Rio', 'Premium', '2025-01-01', '9999-12-31', true),
(3, 'C003', 'Carol', 'carol@mail.com', 'Curitiba', 'Regular', '2025-01-01', '9999-12-31', true);

CREATE SEQUENCE seq_customer_sk START 4;

CREATE TABLE stg_customer_daily (
    customer_id  VARCHAR,
    name         VARCHAR,
    email        VARCHAR,
    city         VARCHAR,
    segment      VARCHAR,
    load_date    DATE
);

INSERT INTO stg_customer_daily VALUES
('C001', 'Alice', 'alice@mail.com', 'Campinas', 'Premium', '2025-02-01'),  -- city and segment changed
('C002', 'Bob', 'bob@mail.com', 'Rio', 'Premium', '2025-02-01'),          -- no change
('C004', 'Diana', 'diana@mail.com', 'Brasília', 'Regular', '2025-02-01'); -- new customer
```

**Tasks:**

1. Implement SCD Type 2 logic:
   - For changed customers (C001): close the current record (set `valid_to` = load_date - 1 day, `is_current` = false) and insert a new record with `valid_from` = load_date, `valid_to` = '9999-12-31', `is_current` = true.
   - For unchanged customers (C002): do nothing.
   - For new customers (C004): insert with `valid_from` = load_date, `is_current` = true.
2. Use `nextval('seq_customer_sk')` for new surrogate keys.

**Grading:**

```sql
-- G1: Total rows = 5 (3 original + 1 closed C001 still there + 1 new C001 version + 1 new C004)
SELECT COUNT(*) FROM dim_customer_scd2;
-- Expected: 5

-- G2: C001 has 2 versions
SELECT COUNT(*) FROM dim_customer_scd2 WHERE customer_id = 'C001';
-- Expected: 2

-- G3: Current C001 is in Campinas, Premium
SELECT city, segment FROM dim_customer_scd2 WHERE customer_id = 'C001' AND is_current = true;
-- Expected: 'Campinas', 'Premium'

-- G4: Old C001 version is closed
SELECT valid_to, is_current FROM dim_customer_scd2 WHERE customer_id = 'C001' AND city = 'São Paulo';
-- Expected: '2025-01-31', false

-- G5: C002 unchanged - still 1 row
SELECT COUNT(*) FROM dim_customer_scd2 WHERE customer_id = 'C002';
-- Expected: 1

-- G6: C004 inserted
SELECT COUNT(*) FROM dim_customer_scd2 WHERE customer_id = 'C004' AND is_current = true;
-- Expected: 1
```

---

### Exercise 14 – Many-to-Many with Bridge Table

**Seed:**

```sql
CREATE TABLE dim_customer_m2m (customer_id INTEGER, customer_name VARCHAR);
CREATE TABLE dim_loyalty_program (program_id INTEGER, program_name VARCHAR, discount_pct DECIMAL(5,2));
CREATE TABLE fact_sales_m2m (sale_id INTEGER, customer_id INTEGER, amount DECIMAL(10,2), sale_date DATE);

INSERT INTO dim_customer_m2m VALUES (1,'Alice'),(2,'Bob'),(3,'Carol');
INSERT INTO dim_loyalty_program VALUES (10,'Gold',10.00),(20,'Silver',5.00),(30,'Platinum',15.00);
INSERT INTO fact_sales_m2m VALUES
(1,1,500,'2025-01-10'),(2,1,300,'2025-01-15'),(3,2,700,'2025-01-12'),
(4,3,200,'2025-01-14'),(5,2,400,'2025-01-20'),(6,3,600,'2025-01-25');

-- Raw membership data
CREATE TABLE raw_memberships (customer_id INTEGER, program_id INTEGER, joined_date DATE);
INSERT INTO raw_memberships VALUES
(1, 10, '2024-06-01'), (1, 30, '2024-11-01'),   -- Alice: Gold + Platinum
(2, 20, '2024-08-01'),                            -- Bob: Silver
(3, 10, '2024-09-01'), (3, 20, '2025-01-01');     -- Carol: Gold + Silver
```

**Tasks:**

1. Create `bridge_customer_program` from `raw_memberships` with: customer_id, program_id, joined_date.
2. Write a query that returns **total revenue per loyalty program** (allocating each customer's full sales to each of their programs — this will double-count customers in multiple programs, which is expected in bridge table analysis).
3. Write a query that returns **customers who belong to more than one program** with their program names listed.

**Grading:**

```sql
-- G1: bridge table has 5 rows
SELECT COUNT(*) FROM bridge_customer_program;
-- Expected: 5

-- G2: Alice appears in 2 programs
SELECT COUNT(*) FROM bridge_customer_program WHERE customer_id = 1;
-- Expected: 2

-- G3: Revenue for Gold program (Alice 800 + Carol 800 = 1600)
-- Student's query should return this
```

---

### Exercise 15 – Factless Fact Table and Rolling Metrics

**Seed:**

```sql
CREATE TABLE dim_user_login (user_id VARCHAR, user_name VARCHAR, segment VARCHAR);
CREATE TABLE dim_device (device_id INTEGER, device_type VARCHAR, os VARCHAR);

INSERT INTO dim_user_login VALUES ('U1','Alice','Free'),('U2','Bob','Premium'),('U3','Carol','Free'),('U4','Diana','Premium');
INSERT INTO dim_device VALUES (1,'Mobile','iOS'),(2,'Desktop','Windows'),(3,'Mobile','Android');

CREATE TABLE raw_logins (user_id VARCHAR, login_ts TIMESTAMP, device_id INTEGER, feature_used VARCHAR);
INSERT INTO raw_logins VALUES
('U1','2025-01-10 08:00',1,'dashboard'), ('U1','2025-01-10 09:00',1,'reports'),
('U2','2025-01-10 10:00',2,'dashboard'), ('U1','2025-01-11 08:00',1,'dashboard'),
('U3','2025-01-11 11:00',3,'exports'),   ('U2','2025-01-11 14:00',2,'dashboard'),
('U1','2025-01-12 07:00',1,'reports'),   ('U2','2025-01-12 09:00',2,'exports'),
('U4','2025-01-12 10:00',2,'dashboard'), ('U3','2025-01-12 15:00',3,'dashboard'),
('U1','2025-01-13 08:00',1,'dashboard'), ('U2','2025-01-13 12:00',2,'reports'),
('U4','2025-01-14 09:00',2,'dashboard'), ('U1','2025-01-14 10:00',1,'exports'),
('U3','2025-01-15 11:00',3,'dashboard'), ('U2','2025-01-16 08:00',2,'reports');
```

**Tasks:**

1. Create `fact_logins` (a factless fact table): login_date (DATE), user_id, device_id, feature_used. No numeric measures — just the event record. Populate from raw_logins.
2. Write a query for **Daily Active Users (DAU)**: date, distinct user count.
3. Write a query for **7-day rolling active users**: for each date, count distinct users who logged in on that date or the previous 6 days. Use a window/self-join approach.
4. Write a query for **feature adoption by segment**: segment, feature_used, distinct user count.

**Grading:**

```sql
-- G1: fact_logins has 16 rows
SELECT COUNT(*) FROM fact_logins;
-- Expected: 16

-- G2: DAU on 2025-01-12 = 4
-- Student's DAU query should return 4 for Jan 12

-- G3: 7-day rolling on 2025-01-16 should include all 4 users
-- Student's rolling query should return 4 for Jan 16

-- G4: Feature adoption - dashboard used by Free segment users
-- Student's query should return >= 2 users for ('Free', 'dashboard')
```

---

## Section 5: Advanced Modeling Approaches (3 exercises)

### Exercise 16 – Data Vault: Hub, Link, Satellite

**Seed:**

```sql
CREATE TABLE src_crm_customers (customer_id VARCHAR, name VARCHAR, email VARCHAR, city VARCHAR, source_system VARCHAR, load_ts TIMESTAMP);
CREATE TABLE src_ecom_customers (customer_id VARCHAR, name VARCHAR, email VARCHAR, city VARCHAR, source_system VARCHAR, load_ts TIMESTAMP);

INSERT INTO src_crm_customers VALUES
('CRM-001', 'Alice', 'alice@crm.com', 'São Paulo', 'CRM', '2025-01-01 00:00'),
('CRM-002', 'Bob', 'bob@crm.com', 'Rio', 'CRM', '2025-01-01 00:00');

INSERT INTO src_ecom_customers VALUES
('ECOM-A1', 'Alice M.', 'alice@ecom.com', 'São Paulo', 'ECOM', '2025-01-01 00:00'),
('ECOM-B1', 'Robert', 'bob@ecom.com', 'Rio de Janeiro', 'ECOM', '2025-01-01 00:00'),
('ECOM-C1', 'Carol', 'carol@ecom.com', 'Curitiba', 'ECOM', '2025-01-01 00:00');
```

**Tasks:**

1. Create `h_customer` (hub): customer_hash_key (MD5 of business key), customer_bk (the original business key), load_ts, record_source.
2. Create `l_customer_source` (link): link_hash_key, customer_hash_key (FK to hub), source_customer_id, source_system, load_ts.
3. Create `s_customer_details` (satellite): customer_hash_key, name, email, city, load_ts, record_source.
4. Populate all three from both source tables. The hub should contain one entry per unique business key (use the original source ID as the business key).

**Grading:**

```sql
-- G1: Hub has 5 entries (each source customer is a unique business key)
SELECT COUNT(*) FROM h_customer;
-- Expected: 5

-- G2: Link has 5 entries (each mapping source → hub)
SELECT COUNT(*) FROM l_customer_source;
-- Expected: 5

-- G3: Satellite has 5 entries
SELECT COUNT(*) FROM s_customer_details;
-- Expected: 5

-- G4: Hub has hash keys
SELECT COUNT(*) FROM h_customer WHERE customer_hash_key IS NOT NULL AND length(customer_hash_key) = 32;
-- Expected: 5
```

---

### Exercise 17 – Conformed Dimensions Across Fact Tables

**Seed:**

```sql
CREATE TABLE dim_date_conf (date_key DATE PRIMARY KEY, year INT, month INT, day INT);
INSERT INTO dim_date_conf
SELECT dt, YEAR(dt), MONTH(dt), DAY(dt)
FROM generate_series('2025-01-01'::DATE, '2025-03-31'::DATE, INTERVAL 1 DAY) t(dt);

CREATE TABLE dim_product_conf (product_id INT PRIMARY KEY, product_name VARCHAR, category VARCHAR);
INSERT INTO dim_product_conf VALUES (1,'Widget A','Gadgets'),(2,'Widget B','Tools'),(3,'Widget C','Gadgets');

CREATE TABLE raw_sales (sale_id INT, product_id INT, sale_date DATE, revenue DECIMAL(10,2));
INSERT INTO raw_sales VALUES (1,1,'2025-01-15',100),(2,2,'2025-01-20',200),(3,1,'2025-02-10',150),(4,3,'2025-02-15',50);

CREATE TABLE raw_returns (return_id INT, product_id INT, return_date DATE, refund_amount DECIMAL(10,2));
INSERT INTO raw_returns VALUES (1,1,'2025-01-25',100),(2,2,'2025-02-05',200);
```

**Tasks:**

1. Create `fact_sales_conf` (sale_id, product_id FK, sale_date FK to dim_date, revenue).
2. Create `fact_returns_conf` (return_id, product_id FK, return_date FK to dim_date, refund_amount).
3. Write a **drill-across query** that shows, by month and category: total revenue, total refunds, and net revenue (revenue - refunds). Use the conformed dim_product and dim_date to align both fact tables.

**Grading:**

```sql
-- G1: fact_sales_conf has 4 rows
SELECT COUNT(*) FROM fact_sales_conf;
-- Expected: 4

-- G2: fact_returns_conf has 2 rows
SELECT COUNT(*) FROM fact_returns_conf;
-- Expected: 2

-- G3: Drill-across - January Gadgets: revenue=100, refunds=100, net=0
-- G4: Drill-across - February Gadgets: revenue=200, refunds=0, net=200
```

---

### Exercise 18 – Inmon 3NF vs Kimball Star: Build Both

**Seed:**

```sql
CREATE TABLE src_transactions (
    txn_id INT, customer_id INT, customer_name VARCHAR, customer_city VARCHAR, customer_country VARCHAR,
    product_id INT, product_name VARCHAR, category VARCHAR,
    txn_date DATE, quantity INT, amount DECIMAL(10,2)
);
INSERT INTO src_transactions VALUES
(1,1,'Alice','SP','Brazil',101,'Laptop','Electronics','2025-01-10',1,1000),
(2,1,'Alice','SP','Brazil',102,'Mouse','Peripherals','2025-01-11',2,60),
(3,2,'Bob','RJ','Brazil',101,'Laptop','Electronics','2025-01-12',1,1000),
(4,3,'Carol','NYC','USA',103,'Monitor','Electronics','2025-01-13',1,500),
(5,2,'Bob','RJ','Brazil',102,'Mouse','Peripherals','2025-01-15',3,90);
```

**Tasks:**

1. **Inmon approach:** Create normalized 3NF tables: `inmon_customers` (customer_id, customer_name, customer_city, customer_country), `inmon_products` (product_id, product_name, category), `inmon_transactions` (txn_id, customer_id FK, product_id FK, txn_date, quantity, amount). Populate from source.
2. **Kimball approach:** Create star schema: `kimball_dim_customer` (customer_id, customer_name, customer_city, customer_country), `kimball_dim_product` (product_id, product_name, category), `kimball_fact_sales` (txn_id, customer_id, product_id, txn_date, quantity, amount). Populate from source.
3. Write the **same business query** against both models: total amount by country. Name the results `v_inmon_by_country` and `v_kimball_by_country`.

**Grading:**

```sql
-- G1: Both models have correct transaction counts
SELECT COUNT(*) FROM inmon_transactions;
-- Expected: 5
SELECT COUNT(*) FROM kimball_fact_sales;
-- Expected: 5

-- G2: Both country views return identical results
SELECT country, total_amount FROM v_inmon_by_country ORDER BY country;
SELECT country, total_amount FROM v_kimball_by_country ORDER BY country;
-- Expected: Brazil=2150, USA=500

-- G3: Inmon has FKs
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'inmon_transactions' AND constraint_type = 'FOREIGN KEY';
-- Expected: 2
```

---

## Section 6: Semi-Structured Data (2 exercises)

### Exercise 19 – Hybrid Model: Extract JSON Fields

**Seed:**

```sql
CREATE TABLE raw_events (
    event_id   VARCHAR,
    event_ts   TIMESTAMP,
    user_id    VARCHAR,
    event_type VARCHAR,
    properties JSON
);

INSERT INTO raw_events VALUES
('E1', '2025-01-10 09:00', 'U1', 'page_view', '{"url":"/home","browser":"Chrome","device":"mobile","campaign_id":"camp1"}'),
('E2', '2025-01-10 09:05', 'U1', 'click', '{"url":"/products","browser":"Chrome","device":"mobile","element":"buy_btn"}'),
('E3', '2025-01-10 10:00', 'U2', 'page_view', '{"url":"/home","browser":"Firefox","device":"desktop","campaign_id":"camp2"}'),
('E4', '2025-01-11 08:00', 'U3', 'purchase', '{"url":"/checkout","browser":"Safari","device":"mobile","order_id":"O100","amount":99.99}'),
('E5', '2025-01-11 09:00', 'U1', 'page_view', '{"url":"/about","browser":"Chrome","device":"mobile"}');
```

**Tasks:**

1. Create `fact_web_events` with:
   - Promoted (extracted) columns: event_id, event_ts, user_id, event_type, url, browser, device.
   - Remaining JSON kept in a `details` column (JSON type) containing only the fields NOT already extracted.
2. Populate from `raw_events`.
3. Write a query that counts events by device type.
4. Write a query that extracts `campaign_id` from the `details` column for events that have it.

**Grading:**

```sql
-- G1: 5 rows
SELECT COUNT(*) FROM fact_web_events;
-- Expected: 5

-- G2: All URLs extracted
SELECT COUNT(*) FROM fact_web_events WHERE url IS NULL;
-- Expected: 0

-- G3: Events by device - mobile = 3
SELECT COUNT(*) FROM fact_web_events WHERE device = 'mobile';
-- Expected: 3

-- G4: Campaign extraction returns 2 rows
SELECT COUNT(*) FROM fact_web_events WHERE json_extract_string(details, '$.campaign_id') IS NOT NULL;
-- Expected: 2
```

---

### Exercise 20 – Flatten Nested Arrays

**Seed:**

```sql
CREATE TABLE raw_invoices (
    invoice_id VARCHAR,
    customer_id VARCHAR,
    invoice_date DATE,
    line_items JSON
);

INSERT INTO raw_invoices VALUES
('INV-001', 'C1', '2025-01-10', '[{"product":"Laptop","qty":1,"price":999.99},{"product":"Mouse","qty":2,"price":29.99}]'),
('INV-002', 'C2', '2025-01-12', '[{"product":"Monitor","qty":1,"price":499.99}]'),
('INV-003', 'C1', '2025-01-15', '[{"product":"Keyboard","qty":1,"price":79.99},{"product":"USB Hub","qty":3,"price":24.99},{"product":"Mouse","qty":1,"price":29.99}]');
```

**Tasks:**

1. Create `fact_invoice_lines` by flattening the JSON arrays. Each row = one line item. Columns: invoice_id, customer_id, invoice_date, product, quantity, unit_price, line_total (qty * price).
2. Use `UNNEST` or `json_array_elements` to flatten.
3. Write a query that returns total revenue per customer.

**Grading:**

```sql
-- G1: 6 line items total (2 + 1 + 3)
SELECT COUNT(*) FROM fact_invoice_lines;
-- Expected: 6

-- G2: INV-003 has 3 lines
SELECT COUNT(*) FROM fact_invoice_lines WHERE invoice_id = 'INV-003';
-- Expected: 3

-- G3: C1 total revenue = 999.99 + 59.98 + 79.99 + 74.97 + 29.99 = 1244.92
SELECT SUM(line_total) FROM fact_invoice_lines WHERE customer_id = 'C1';
-- Expected: 1244.92

-- G4: line_total computed correctly for Laptop
SELECT line_total FROM fact_invoice_lines WHERE invoice_id = 'INV-001' AND product = 'Laptop';
-- Expected: 999.99
```

---

## Section 7: File Formats & Partitioning (3 exercises)

### Exercise 21 – Read and Write Multiple File Formats

**Seed:**

```sql
CREATE TABLE sample_data (id INTEGER, name VARCHAR, amount DECIMAL(10,2), event_date DATE);
INSERT INTO sample_data VALUES
(1, 'Alice', 100.50, '2025-01-10'), (2, 'Bob', 200.75, '2025-01-11'),
(3, 'Carol', 300.00, '2025-01-12'), (4, 'Diana', 150.25, '2025-01-13');
```

**Tasks:**

1. Export `sample_data` to CSV: `COPY sample_data TO '/tmp/ex21_output.csv' (HEADER, DELIMITER ',');`
2. Export `sample_data` to Parquet: `COPY sample_data TO '/tmp/ex21_output.parquet' (FORMAT PARQUET);`
3. Export `sample_data` to JSON: `COPY sample_data TO '/tmp/ex21_output.json' (FORMAT JSON, ARRAY true);`
4. Read back each file into a new table: `csv_reimport`, `parquet_reimport`, `json_reimport`.
5. Write a query that validates all three reimported tables have the same row count and total amount.

**Grading:**

```sql
-- G1: All three reimport tables exist
SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('csv_reimport','parquet_reimport','json_reimport');
-- Expected: 3

-- G2: Each has 4 rows
SELECT COUNT(*) FROM csv_reimport;
-- Expected: 4
SELECT COUNT(*) FROM parquet_reimport;
-- Expected: 4

-- G3: Amounts match
SELECT SUM(amount) FROM parquet_reimport;
-- Expected: 751.50
```

---

### Exercise 22 – Partitioned Parquet Export

**Seed:**

```sql
CREATE TABLE event_log (event_id INTEGER, event_date DATE, country VARCHAR, event_type VARCHAR, value DECIMAL(10,2));
INSERT INTO event_log VALUES
(1, '2025-01-10', 'BR', 'click', 1.00),    (2, '2025-01-10', 'US', 'click', 2.00),
(3, '2025-01-10', 'BR', 'purchase', 50.00), (4, '2025-01-11', 'US', 'click', 1.50),
(5, '2025-01-11', 'BR', 'click', 1.00),    (6, '2025-01-11', 'US', 'purchase', 75.00),
(7, '2025-01-12', 'BR', 'purchase', 30.00), (8, '2025-01-12', 'US', 'click', 2.50);
```

**Tasks:**

1. Export `event_log` to Parquet **partitioned by event_date**: `COPY event_log TO '/tmp/ex22_partitioned' (FORMAT PARQUET, PARTITION_BY (event_date));`
2. Read back only the partition for `2025-01-11` into a table called `events_jan11`.
3. Write a query that returns the total value per country for that single partition.

**Grading:**

```sql
-- G1: events_jan11 has 3 rows
SELECT COUNT(*) FROM events_jan11;
-- Expected: 3

-- G2: BR total for Jan 11 = 1.00
SELECT SUM(value) FROM events_jan11 WHERE country = 'BR';
-- Expected: 1.00

-- G3: US total for Jan 11 = 76.50
SELECT SUM(value) FROM events_jan11 WHERE country = 'US';
-- Expected: 76.50
```

---

### Exercise 23 – Compression Comparison

**Seed:**

```sql
CREATE TABLE large_data AS
SELECT
    i AS id,
    'user_' || (i % 1000) AS user_id,
    '2025-01-01'::DATE + (i % 90) AS event_date,
    CASE WHEN i % 3 = 0 THEN 'click' WHEN i % 3 = 1 THEN 'view' ELSE 'purchase' END AS event_type,
    ROUND(RANDOM() * 1000, 2) AS amount
FROM generate_series(1, 100000) t(i);
```

**Tasks:**

1. Export `large_data` to three Parquet files with different compression:
   - `/tmp/ex23_snappy.parquet` with SNAPPY compression.
   - `/tmp/ex23_zstd.parquet` with ZSTD compression.
   - `/tmp/ex23_none.parquet` with no compression (UNCOMPRESSED).
2. Create a table `compression_comparison` with columns: compression_type (VARCHAR), file_path (VARCHAR). Insert the three file paths.
3. Read each file back and verify row counts match (100,000 each).

**Grading:**

```sql
-- G1: compression_comparison has 3 rows
SELECT COUNT(*) FROM compression_comparison;
-- Expected: 3

-- G2: Each file readable with correct row count
SELECT COUNT(*) FROM read_parquet('/tmp/ex23_snappy.parquet');
-- Expected: 100000
SELECT COUNT(*) FROM read_parquet('/tmp/ex23_zstd.parquet');
-- Expected: 100000
```

---

## Section 8: Data Lifecycle & CDC (3 exercises)

### Exercise 24 – Hot/Cold Table Splitting

**Seed:**

```sql
CREATE TABLE fact_sales_full (
    sale_id INTEGER, sale_date DATE, customer_id INTEGER,
    product_id INTEGER, amount DECIMAL(10,2)
);

INSERT INTO fact_sales_full
SELECT i, '2020-01-01'::DATE + (i % 1826), (i % 50) + 1, (i % 20) + 1, ROUND(RANDOM() * 500, 2)
FROM generate_series(1, 10000) t(i);
```

**Tasks:**

1. Create `fact_sales_hot` containing only rows from the last 6 months (relative to the max date in the table).
2. Create `fact_sales_cold` containing everything older than 6 months.
3. Create a view `v_fact_sales_all` that UNIONs both tables seamlessly.
4. Verify that `v_fact_sales_all` returns the same row count as the original table.

**Grading:**

```sql
-- G1: hot + cold = full
SELECT (SELECT COUNT(*) FROM fact_sales_hot) + (SELECT COUNT(*) FROM fact_sales_cold) AS total;
-- Expected: 10000

-- G2: No overlap
SELECT COUNT(*) FROM fact_sales_hot h JOIN fact_sales_cold c ON h.sale_id = c.sale_id;
-- Expected: 0

-- G3: View returns all rows
SELECT COUNT(*) FROM v_fact_sales_all;
-- Expected: 10000

-- G4: Hot table has only recent data
SELECT COUNT(*) FROM fact_sales_hot WHERE sale_date < (SELECT MAX(sale_date) - INTERVAL '6 months' FROM fact_sales_full);
-- Expected: 0
```

---

### Exercise 25 – Simulate CDC with Incremental Loads

**Seed:**

```sql
-- Target table (existing warehouse state)
CREATE TABLE warehouse_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR,
    category VARCHAR,
    price DECIMAL(10,2),
    last_updated DATE
);

INSERT INTO warehouse_products VALUES
(1, 'Laptop', 'Electronics', 999.99, '2025-01-01'),
(2, 'Mouse', 'Peripherals', 29.99, '2025-01-01'),
(3, 'Keyboard', 'Peripherals', 79.99, '2025-01-01');

-- CDC change log (simulated)
CREATE TABLE cdc_product_changes (
    product_id INTEGER,
    product_name VARCHAR,
    category VARCHAR,
    price DECIMAL(10,2),
    change_type VARCHAR,   -- 'INSERT', 'UPDATE', 'DELETE'
    change_ts TIMESTAMP
);

INSERT INTO cdc_product_changes VALUES
(2, 'Wireless Mouse', 'Peripherals', 39.99, 'UPDATE', '2025-02-01 10:00'),
(4, 'Webcam', 'Peripherals', 59.99, 'INSERT', '2025-02-01 11:00'),
(3, NULL, NULL, NULL, 'DELETE', '2025-02-01 12:00');
```

**Tasks:**

1. Apply the CDC changes to `warehouse_products`:
   - UPDATE product 2 with new name and price.
   - INSERT product 4.
   - DELETE product 3.
2. After applying, `warehouse_products` should reflect the final state.
3. Create a `cdc_audit_log` table that records what was applied: product_id, change_type, applied_at (current_timestamp).

**Grading:**

```sql
-- G1: 3 products remain (1 original + 1 updated + 1 new - 1 deleted)
SELECT COUNT(*) FROM warehouse_products;
-- Expected: 3

-- G2: Product 2 updated
SELECT product_name, price FROM warehouse_products WHERE product_id = 2;
-- Expected: 'Wireless Mouse', 39.99

-- G3: Product 3 deleted
SELECT COUNT(*) FROM warehouse_products WHERE product_id = 3;
-- Expected: 0

-- G4: Product 4 inserted
SELECT product_name FROM warehouse_products WHERE product_id = 4;
-- Expected: 'Webcam'

-- G5: Audit log has 3 entries
SELECT COUNT(*) FROM cdc_audit_log;
-- Expected: 3
```

---

### Exercise 26 – ACID Transactions

**Seed:**

```sql
CREATE TABLE account_balances (account_id INTEGER PRIMARY KEY, balance DECIMAL(10,2));
INSERT INTO account_balances VALUES (1, 1000.00), (2, 500.00), (3, 750.00);
```

**Tasks:**

1. Write a transaction that transfers 200.00 from account 1 to account 2:
   - Debit account 1 by 200.
   - Credit account 2 by 200.
   - Both operations must be atomic (wrapped in BEGIN/COMMIT).
2. Write a transaction that attempts to withdraw 2000.00 from account 3 (more than the balance). This transaction should ROLLBACK.
3. After both transactions, verify final balances: account 1 = 800, account 2 = 700, account 3 = 750.

**Grading:**

```sql
-- G1: Account 1 balance
SELECT balance FROM account_balances WHERE account_id = 1;
-- Expected: 800.00

-- G2: Account 2 balance
SELECT balance FROM account_balances WHERE account_id = 2;
-- Expected: 700.00

-- G3: Account 3 unchanged (rollback worked)
SELECT balance FROM account_balances WHERE account_id = 3;
-- Expected: 750.00

-- G4: Total balance unchanged (conservation)
SELECT SUM(balance) FROM account_balances;
-- Expected: 2250.00
```

---

## Section 9: Indexes & Query Optimization (2 exercises)

### Exercise 27 – Create and Evaluate Indexes

**Seed:**

```sql
CREATE TABLE customer_events AS
SELECT
    i AS event_id,
    'CUST-' || LPAD((i % 500)::VARCHAR, 4, '0') AS customer_id,
    '2025-01-01'::DATE + (i % 60) AS event_date,
    CASE WHEN i % 4 = 0 THEN 'purchase' WHEN i % 4 = 1 THEN 'view' WHEN i % 4 = 2 THEN 'click' ELSE 'login' END AS event_type,
    ROUND(RANDOM() * 100, 2) AS value
FROM generate_series(1, 200000) t(i);
```

**Tasks:**

1. Write a point lookup query: find all events for customer `'CUST-0042'`. Note the result count.
2. Create an **index** on `customer_id`: `CREATE INDEX idx_customer_events_cid ON customer_events(customer_id);`
3. Run `EXPLAIN` on the same query before and after the index. Save the explain outputs into tables:
   - `explain_no_index` (create before adding the index)
   - `explain_with_index` (create after adding the index)
4. Write a query to count total events of type `'purchase'` per event_date for the month of January 2025.

**Grading:**

```sql
-- G1: Index exists
SELECT COUNT(*) FROM duckdb_indexes() WHERE table_name = 'customer_events' AND index_name = 'idx_customer_events_cid';
-- Expected: 1

-- G2: Point lookup for CUST-0042 returns 400 rows
SELECT COUNT(*) FROM customer_events WHERE customer_id = 'CUST-0042';
-- Expected: 400

-- G3: Both explain tables exist
SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('explain_no_index','explain_with_index');
-- Expected: 2
```

---

### Exercise 28 – Columnar Scan Optimization

**Seed:**

```sql
CREATE TABLE wide_events AS
SELECT
    i AS event_id,
    '2025-01-01'::DATE + (i % 90) AS event_date,
    'U' || (i % 1000) AS user_id,
    CASE WHEN i % 5 = 0 THEN 'purchase' ELSE 'view' END AS event_type,
    ROUND(RANDOM() * 500, 2) AS amount,
    'payload_' || REPEAT('x', 100) AS col_a,
    'payload_' || REPEAT('y', 100) AS col_b,
    'payload_' || REPEAT('z', 100) AS col_c,
    md5(i::VARCHAR) AS hash_col
FROM generate_series(1, 50000) t(i);
```

**Tasks:**

1. Create a **narrow projection** table `events_core` containing only: event_id, event_date, user_id, event_type, amount. Populate from `wide_events`.
2. Create an **extended attributes** table `events_extended` containing: event_id, col_a, col_b, col_c, hash_col. Populate from `wide_events`.
3. Write a query that computes total purchase amount per month using only `events_core`.
4. Write a query that joins `events_core` and `events_extended` for a specific event_id to demonstrate on-demand access to extended columns.

**Grading:**

```sql
-- G1: events_core has 50000 rows with 5 columns
SELECT COUNT(*) FROM events_core;
-- Expected: 50000
SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'events_core';
-- Expected: 5

-- G2: events_extended has 50000 rows with 5 columns
SELECT COUNT(*) FROM events_extended;
-- Expected: 50000

-- G3: No data loss - join produces full row
SELECT COUNT(*) FROM events_core c JOIN events_extended e ON c.event_id = e.event_id;
-- Expected: 50000
```

---

## Section 10: Data Contracts & Quality (2 exercises)

### Exercise 29 – Schema Constraints as Contracts

**Seed:**

```sql
-- The "contract": this is the expected schema
-- Student must create a table that enforces these rules
```

**Tasks:**

1. Create `fact_orders_contracted` with the following contract enforced via DDL constraints:
   - `order_id` INTEGER, PRIMARY KEY, NOT NULL
   - `customer_id` INTEGER, NOT NULL
   - `product_id` INTEGER, NOT NULL
   - `order_date` DATE, NOT NULL
   - `quantity` INTEGER, NOT NULL, CHECK (quantity > 0)
   - `unit_price` DECIMAL(10,2), NOT NULL, CHECK (unit_price >= 0)
   - `total_amount` DECIMAL(10,2), NOT NULL
2. Insert 5 valid rows.
3. Demonstrate that the following inserts **fail** (write them as comments or in a separate test block):
   - A row with NULL `customer_id`.
   - A row with `quantity = 0`.
   - A row with negative `unit_price`.

**Grading:**

```sql
-- G1: Table exists with constraints
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'fact_orders_contracted' AND constraint_type = 'PRIMARY KEY';
-- Expected: 1
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'fact_orders_contracted' AND constraint_type = 'CHECK';
-- Expected: >= 2
SELECT COUNT(*) FROM duckdb_constraints() WHERE table_name = 'fact_orders_contracted' AND constraint_type = 'NOT NULL';
-- Expected: >= 5

-- G2: 5 valid rows inserted
SELECT COUNT(*) FROM fact_orders_contracted;
-- Expected: 5

-- G3: All quantities positive
SELECT COUNT(*) FROM fact_orders_contracted WHERE quantity <= 0;
-- Expected: 0
```

---

### Exercise 30 – Data Quality Checks and SLA Metrics

**Seed:**

```sql
CREATE TABLE fact_daily_sales (
    sale_id INTEGER, sale_date DATE, customer_id INTEGER,
    product_id INTEGER, amount DECIMAL(10,2), loaded_at TIMESTAMP
);

INSERT INTO fact_daily_sales VALUES
(1, '2025-01-10', 101, 201, 100.00, '2025-01-10 06:00'),
(2, '2025-01-10', 102, 202, NULL, '2025-01-10 06:00'),        -- NULL amount
(3, '2025-01-10', 101, 201, 100.00, '2025-01-10 06:00'),      -- duplicate of row 1
(4, '2025-01-11', 103, 203, 250.00, '2025-01-11 06:00'),
(5, '2025-01-11', NULL, 204, 75.00, '2025-01-11 06:00'),       -- NULL customer_id
(6, '2025-01-12', 104, 205, 300.00, '2025-01-12 14:00'),       -- late load (14:00 instead of 06:00)
(7, '2025-01-12', 105, 206, -50.00, '2025-01-12 06:00'),       -- negative amount
(8, '2025-01-12', 106, 207, 125.00, '2025-01-12 06:00');
```

**Tasks:**

1. Create a `dq_report` table that computes the following data quality metrics for `fact_daily_sales`:
   - `total_rows` (INTEGER)
   - `null_amount_count` (INTEGER): rows where amount IS NULL
   - `null_customer_count` (INTEGER): rows where customer_id IS NULL
   - `duplicate_count` (INTEGER): number of rows that are duplicates (same sale_date, customer_id, product_id, amount appearing more than once)
   - `negative_amount_count` (INTEGER): rows where amount < 0
   - `late_load_count` (INTEGER): rows where loaded_at is after 08:00 on the sale_date
   - `completeness_pct` (DECIMAL): percentage of rows with NO nulls in amount and customer_id
   - `validity_pct` (DECIMAL): percentage of rows with amount >= 0 (among non-null amounts)
2. Populate it with a single INSERT ... SELECT.

**Grading:**

```sql
-- G1: dq_report has exactly 1 row
SELECT COUNT(*) FROM dq_report;
-- Expected: 1

-- G2: Correct metrics
SELECT total_rows FROM dq_report;
-- Expected: 8

SELECT null_amount_count FROM dq_report;
-- Expected: 1

SELECT null_customer_count FROM dq_report;
-- Expected: 1

SELECT duplicate_count FROM dq_report;
-- Expected: 1

SELECT negative_amount_count FROM dq_report;
-- Expected: 1

SELECT late_load_count FROM dq_report;
-- Expected: 1
```
