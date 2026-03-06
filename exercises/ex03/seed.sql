CREATE TABLE raw_products (
    product_id       INTEGER,
    product_name     VARCHAR,
    category_name    VARCHAR,
    category_group   VARCHAR,
    tax_rate         DECIMAL(5,2),
    unit_of_measure  VARCHAR
);

INSERT INTO raw_products VALUES
(1, 'Laptop Pro', 'Electronics', 'Tech', 15.00, 'unit'),
(2, 'Phone X', 'Electronics', 'Tech', 15.00, 'unit'),
(3, 'Desk Chair', 'Furniture', 'Office', 10.00, 'unit'),
(4, 'Standing Desk', 'Furnitur', 'Office', 10.00, 'unit'),   -- typo in category
(5, 'USB Cable', 'Electronicss', 'Tech', 15.00, 'unit'),     -- typo in category
(6, 'Monitor 27"', 'Electronics', 'Tech', 15.00, 'unit'),
(7, 'Bookshelf', 'Furniture', 'Office', 10.00, 'unit');
