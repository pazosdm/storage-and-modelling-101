-- Target table (existing warehouse state)
CREATE TABLE warehouse_products (
    product_id   INTEGER PRIMARY KEY,
    product_name VARCHAR,
    category     VARCHAR,
    price        DECIMAL(10,2),
    last_updated DATE
);

INSERT INTO warehouse_products VALUES
(1, 'Laptop', 'Electronics', 999.99, '2025-01-01'),
(2, 'Mouse', 'Peripherals', 29.99, '2025-01-01'),
(3, 'Keyboard', 'Peripherals', 79.99, '2025-01-01');

-- CDC change log (simulated)
CREATE TABLE cdc_product_changes (
    product_id   INTEGER,
    product_name VARCHAR,
    category     VARCHAR,
    price        DECIMAL(10,2),
    change_type  VARCHAR,   -- 'INSERT', 'UPDATE', 'DELETE'
    change_ts    TIMESTAMP
);

INSERT INTO cdc_product_changes VALUES
(2, 'Wireless Mouse', 'Peripherals', 39.99, 'UPDATE', '2025-02-01 10:00'),
(4, 'Webcam', 'Peripherals', 59.99, 'INSERT', '2025-02-01 11:00'),
(3, NULL, NULL, NULL, 'DELETE', '2025-02-01 12:00');
