CREATE TABLE dim_customer_scd2 (
    customer_sk  INTEGER,
    customer_id  VARCHAR,
    name         VARCHAR,
    email        VARCHAR,
    city         VARCHAR,
    segment      VARCHAR,
    valid_from   DATE,
    valid_to     DATE,
    is_current   BOOLEAN
);

INSERT INTO dim_customer_scd2 VALUES
(1, 'C001', 'Alice', 'alice@mail.com', 'São Paulo', 'Regular', '2025-01-01', '9999-12-31', true),
(2, 'C002', 'Bob', 'bob@mail.com', 'Rio', 'Premium', '2025-01-01', '9999-12-31', true),
(3, 'C003', 'Carol', 'carol@mail.com', 'Curitiba', 'Regular', '2025-01-01', '9999-12-31', true);

CREATE SEQUENCE seq_customer_sk START 4;

CREATE TABLE stg_customer_daily (
    customer_id  VARCHAR,
    name         VARCHAR,
    email        VARCHAR,
    city         VARCHAR,
    segment      VARCHAR,
    load_date    DATE
);

INSERT INTO stg_customer_daily VALUES
('C001', 'Alice', 'alice@mail.com', 'Campinas', 'Premium', '2025-02-01'),  -- city and segment changed
('C002', 'Bob', 'bob@mail.com', 'Rio', 'Premium', '2025-02-01'),           -- no change
('C004', 'Diana', 'diana@mail.com', 'Brasília', 'Regular', '2025-02-01');  -- new customer
