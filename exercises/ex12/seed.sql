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
