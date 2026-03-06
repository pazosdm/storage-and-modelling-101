CREATE TABLE raw_events (
    event_id   VARCHAR,
    event_ts   TIMESTAMP,
    user_id    VARCHAR,
    event_type VARCHAR,
    properties JSON
);

INSERT INTO raw_events VALUES
('E1', '2025-01-10 09:00', 'U1', 'page_view', '{"url":"/home","browser":"Chrome","device":"mobile","campaign_id":"camp1"}'),
('E2', '2025-01-10 09:05', 'U1', 'click', '{"url":"/products","browser":"Chrome","device":"mobile","element":"buy_btn"}'),
('E3', '2025-01-10 10:00', 'U2', 'page_view', '{"url":"/home","browser":"Firefox","device":"desktop","campaign_id":"camp2"}'),
('E4', '2025-01-11 08:00', 'U3', 'purchase', '{"url":"/checkout","browser":"Safari","device":"mobile","order_id":"O100","amount":99.99}'),
('E5', '2025-01-11 09:00', 'U1', 'page_view', '{"url":"/about","browser":"Chrome","device":"mobile"}');
