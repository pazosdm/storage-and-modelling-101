CREATE TABLE dim_customer_m2m (customer_id INTEGER, customer_name VARCHAR);
CREATE TABLE dim_loyalty_program (program_id INTEGER, program_name VARCHAR, discount_pct DECIMAL(5,2));
CREATE TABLE fact_sales_m2m (sale_id INTEGER, customer_id INTEGER, amount DECIMAL(10,2), sale_date DATE);

INSERT INTO dim_customer_m2m VALUES (1,'Alice'),(2,'Bob'),(3,'Carol');
INSERT INTO dim_loyalty_program VALUES (10,'Gold',10.00),(20,'Silver',5.00),(30,'Platinum',15.00);
INSERT INTO fact_sales_m2m VALUES
(1,1,500.00,'2025-01-10'),(2,1,300.00,'2025-01-15'),(3,2,700.00,'2025-01-12'),
(4,3,200.00,'2025-01-14'),(5,2,400.00,'2025-01-20'),(6,3,600.00,'2025-01-25');

-- Raw membership data
CREATE TABLE raw_memberships (customer_id INTEGER, program_id INTEGER, joined_date DATE);
INSERT INTO raw_memberships VALUES
(1, 10, '2024-06-01'), (1, 30, '2024-11-01'),   -- Alice: Gold + Platinum
(2, 20, '2024-08-01'),                            -- Bob: Silver
(3, 10, '2024-09-01'), (3, 20, '2025-01-01');     -- Carol: Gold + Silver
