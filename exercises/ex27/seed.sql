CREATE TABLE customer_events AS
SELECT
    i AS event_id,
    'CUST-' || LPAD((i % 500)::VARCHAR, 4, '0') AS customer_id,
    '2025-01-01'::DATE + (i % 60) AS event_date,
    CASE WHEN i % 4 = 0 THEN 'purchase' WHEN i % 4 = 1 THEN 'view' WHEN i % 4 = 2 THEN 'click' ELSE 'login' END AS event_type,
    ROUND(RANDOM() * 100, 2) AS value
FROM generate_series(1, 200000) t(i);
