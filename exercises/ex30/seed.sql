CREATE TABLE fact_daily_sales (
    sale_id     INTEGER,
    sale_date   DATE,
    customer_id INTEGER,
    product_id  INTEGER,
    amount      DECIMAL(10,2),
    loaded_at   TIMESTAMP
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
