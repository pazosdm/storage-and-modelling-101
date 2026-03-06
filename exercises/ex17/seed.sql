CREATE TABLE dim_date_conf (date_key DATE PRIMARY KEY, year INT, month INT, day INT);
INSERT INTO dim_date_conf
SELECT dt, YEAR(dt), MONTH(dt), DAY(dt)
FROM generate_series('2025-01-01'::DATE, '2025-03-31'::DATE, INTERVAL 1 DAY) t(dt);

CREATE TABLE dim_product_conf (product_id INT PRIMARY KEY, product_name VARCHAR, category VARCHAR);
INSERT INTO dim_product_conf VALUES (1,'Widget A','Gadgets'),(2,'Widget B','Tools'),(3,'Widget C','Gadgets');

CREATE TABLE raw_sales (sale_id INT, product_id INT, sale_date DATE, revenue DECIMAL(10,2));
INSERT INTO raw_sales VALUES (1,1,'2025-01-15',100.00),(2,2,'2025-01-20',200.00),(3,1,'2025-02-10',150.00),(4,3,'2025-02-15',50.00);

CREATE TABLE raw_returns (return_id INT, product_id INT, return_date DATE, refund_amount DECIMAL(10,2));
INSERT INTO raw_returns VALUES (1,1,'2025-01-25',100.00),(2,2,'2025-02-05',200.00);
