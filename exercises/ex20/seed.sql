CREATE TABLE raw_invoices (
    invoice_id  VARCHAR,
    customer_id VARCHAR,
    invoice_date DATE,
    line_items  JSON
);

INSERT INTO raw_invoices VALUES
('INV-001', 'C1', '2025-01-10', '[{"product":"Laptop","qty":1,"price":999.99},{"product":"Mouse","qty":2,"price":29.99}]'),
('INV-002', 'C2', '2025-01-12', '[{"product":"Monitor","qty":1,"price":499.99}]'),
('INV-003', 'C1', '2025-01-15', '[{"product":"Keyboard","qty":1,"price":79.99},{"product":"USB Hub","qty":3,"price":24.99},{"product":"Mouse","qty":1,"price":29.99}]');
