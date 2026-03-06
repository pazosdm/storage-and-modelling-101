CREATE TABLE raw_web_sessions (
    session_id    VARCHAR,
    user_id       VARCHAR,
    session_start TIMESTAMP,
    session_end   TIMESTAMP,
    channel       VARCHAR,
    device        VARCHAR,
    page_views    INTEGER,
    converted     BOOLEAN
);

CREATE TABLE raw_orders (
    order_id    VARCHAR,
    user_id     VARCHAR,
    order_ts    TIMESTAMP,
    channel     VARCHAR,
    country     VARCHAR,
    order_total DECIMAL(10,2)
);

INSERT INTO raw_web_sessions VALUES
('S1', 'U1', '2025-01-10 09:00', '2025-01-10 09:15', 'organic', 'mobile', 5, true),
('S2', 'U2', '2025-01-10 10:00', '2025-01-10 10:05', 'paid', 'desktop', 3, false),
('S3', 'U1', '2025-01-11 14:00', '2025-01-11 14:30', 'organic', 'mobile', 8, true),
('S4', 'U3', '2025-01-11 16:00', '2025-01-11 16:10', 'email', 'mobile', 2, false),
('S5', 'U2', '2025-01-12 08:00', '2025-01-12 08:20', 'paid', 'desktop', 6, true);

INSERT INTO raw_orders VALUES
('O1', 'U1', '2025-01-10 09:12', 'organic', 'Brazil', 150.00),
('O2', 'U1', '2025-01-11 14:25', 'organic', 'Brazil', 200.00),
('O3', 'U2', '2025-01-12 08:18', 'paid', 'USA', 75.00);
