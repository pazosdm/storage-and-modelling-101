CREATE TABLE wide_events AS
SELECT
    i AS event_id,
    '2025-01-01'::DATE + (i % 90) AS event_date,
    'U' || (i % 1000) AS user_id,
    CASE WHEN i % 5 = 0 THEN 'purchase' ELSE 'view' END AS event_type,
    ROUND(RANDOM() * 500, 2) AS amount,
    'payload_' || REPEAT('x', 100) AS col_a,
    'payload_' || REPEAT('y', 100) AS col_b,
    'payload_' || REPEAT('z', 100) AS col_c,
    md5(i::VARCHAR) AS hash_col
FROM generate_series(1, 50000) t(i);
