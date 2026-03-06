CREATE TABLE fact_sales_full (
    sale_id INTEGER, sale_date DATE, customer_id INTEGER,
    product_id INTEGER, amount DECIMAL(10,2)
);

INSERT INTO fact_sales_full
SELECT i, '2020-01-01'::DATE + (i % 1826), (i % 50) + 1, (i % 20) + 1, ROUND(RANDOM() * 500, 2)
FROM generate_series(1, 10000) t(i);
