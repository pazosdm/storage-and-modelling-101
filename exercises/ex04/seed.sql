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
