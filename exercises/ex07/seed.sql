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
