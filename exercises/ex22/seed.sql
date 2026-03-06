CREATE TABLE event_log (event_id INTEGER, event_date DATE, country VARCHAR, event_type VARCHAR, value DECIMAL(10,2));
INSERT INTO event_log VALUES
(1, '2025-01-10', 'BR', 'click', 1.00),    (2, '2025-01-10', 'US', 'click', 2.00),
(3, '2025-01-10', 'BR', 'purchase', 50.00), (4, '2025-01-11', 'US', 'click', 1.50),
(5, '2025-01-11', 'BR', 'click', 1.00),    (6, '2025-01-11', 'US', 'purchase', 75.00),
(7, '2025-01-12', 'BR', 'purchase', 30.00), (8, '2025-01-12', 'US', 'click', 2.50);
