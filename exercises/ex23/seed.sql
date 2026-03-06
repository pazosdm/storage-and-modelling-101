CREATE TABLE large_data AS
SELECT
    i AS id,
    'user_' || (i % 1000) AS user_id,
    '2025-01-01'::DATE + (i % 90) AS event_date,
    CASE WHEN i % 3 = 0 THEN 'click' WHEN i % 3 = 1 THEN 'view' ELSE 'purchase' END AS event_type,
    ROUND(RANDOM() * 1000, 2) AS amount
FROM generate_series(1, 100000) t(i);
