CREATE TABLE src_transactions (
    txn_id INT, customer_id INT, customer_name VARCHAR, customer_city VARCHAR, customer_country VARCHAR,
    product_id INT, product_name VARCHAR, category VARCHAR,
    txn_date DATE, quantity INT, amount DECIMAL(10,2)
);
INSERT INTO src_transactions VALUES
(1,1,'Alice','SP','Brazil',101,'Laptop','Electronics','2025-01-10',1,1000.00),
(2,1,'Alice','SP','Brazil',102,'Mouse','Peripherals','2025-01-11',2,60.00),
(3,2,'Bob','RJ','Brazil',101,'Laptop','Electronics','2025-01-12',1,1000.00),
(4,3,'Carol','NYC','USA',103,'Monitor','Electronics','2025-01-13',1,500.00),
(5,2,'Bob','RJ','Brazil',102,'Mouse','Peripherals','2025-01-15',3,90.00);
