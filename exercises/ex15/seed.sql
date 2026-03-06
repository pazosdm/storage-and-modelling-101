CREATE TABLE dim_user_login (user_id VARCHAR, user_name VARCHAR, segment VARCHAR);
CREATE TABLE dim_device (device_id INTEGER, device_type VARCHAR, os VARCHAR);

INSERT INTO dim_user_login VALUES ('U1','Alice','Free'),('U2','Bob','Premium'),('U3','Carol','Free'),('U4','Diana','Premium');
INSERT INTO dim_device VALUES (1,'Mobile','iOS'),(2,'Desktop','Windows'),(3,'Mobile','Android');

CREATE TABLE raw_logins (user_id VARCHAR, login_ts TIMESTAMP, device_id INTEGER, feature_used VARCHAR);
INSERT INTO raw_logins VALUES
('U1','2025-01-10 08:00',1,'dashboard'), ('U1','2025-01-10 09:00',1,'reports'),
('U2','2025-01-10 10:00',2,'dashboard'), ('U1','2025-01-11 08:00',1,'dashboard'),
('U3','2025-01-11 11:00',3,'exports'),   ('U2','2025-01-11 14:00',2,'dashboard'),
('U1','2025-01-12 07:00',1,'reports'),   ('U2','2025-01-12 09:00',2,'exports'),
('U4','2025-01-12 10:00',2,'dashboard'), ('U3','2025-01-12 15:00',3,'dashboard'),
('U1','2025-01-13 08:00',1,'dashboard'), ('U2','2025-01-13 12:00',2,'reports'),
('U4','2025-01-14 09:00',2,'dashboard'), ('U1','2025-01-14 10:00',1,'exports'),
('U3','2025-01-15 11:00',3,'dashboard'), ('U2','2025-01-16 08:00',2,'reports');
