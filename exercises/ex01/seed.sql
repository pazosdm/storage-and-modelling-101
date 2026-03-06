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
