CREATE TABLE src_crm_customers (customer_id VARCHAR, name VARCHAR, email VARCHAR, city VARCHAR, source_system VARCHAR, load_ts TIMESTAMP);
CREATE TABLE src_ecom_customers (customer_id VARCHAR, name VARCHAR, email VARCHAR, city VARCHAR, source_system VARCHAR, load_ts TIMESTAMP);

INSERT INTO src_crm_customers VALUES
('CRM-001', 'Alice', 'alice@crm.com', 'São Paulo', 'CRM', '2025-01-01 00:00'),
('CRM-002', 'Bob', 'bob@crm.com', 'Rio', 'CRM', '2025-01-01 00:00');

INSERT INTO src_ecom_customers VALUES
('ECOM-A1', 'Alice M.', 'alice@ecom.com', 'São Paulo', 'ECOM', '2025-01-01 00:00'),
('ECOM-B1', 'Robert', 'bob@ecom.com', 'Rio de Janeiro', 'ECOM', '2025-01-01 00:00'),
('ECOM-C1', 'Carol', 'carol@ecom.com', 'Curitiba', 'ECOM', '2025-01-01 00:00');
