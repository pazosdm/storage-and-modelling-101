-- Standalone seed: star schema created directly (no dependency on ex07 solution)
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
    (1001, 1, 101, '2025-01-10'::DATE, 1, 999.99::DECIMAL(10,2), 999.99::DECIMAL(10,2)),
    (1001, 1, 102, '2025-01-10'::DATE, 2, 29.99::DECIMAL(10,2),  59.98::DECIMAL(10,2)),
    (1002, 2, 103, '2025-01-12'::DATE, 1, 499.99::DECIMAL(10,2), 499.99::DECIMAL(10,2)),
    (1003, 1, 102, '2025-01-15'::DATE, 5, 29.99::DECIMAL(10,2),  149.95::DECIMAL(10,2)),
    (1004, 3, 101, '2025-02-01'::DATE, 1, 999.99::DECIMAL(10,2), 999.99::DECIMAL(10,2)),
    (1004, 3, 103, '2025-02-01'::DATE, 2, 499.99::DECIMAL(10,2), 999.98::DECIMAL(10,2))
) t(order_id, customer_id, product_id, order_date, quantity, unit_price, total_amount);
