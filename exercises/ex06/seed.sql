CREATE TABLE raw_book_authors (
    book_id     INTEGER,
    book_title  VARCHAR,
    author_name VARCHAR,
    genre       VARCHAR,
    pub_year    INTEGER
);

INSERT INTO raw_book_authors VALUES
(1, 'Data Warehouse Toolkit', 'Ralph Kimball', 'Technical', 2013),
(1, 'Data Warehouse Toolkit', 'Margy Ross', 'Technical', 2013),
(2, 'Building the DW', 'Ralph Kimball', 'Technical', 2011),
(3, 'Designing Data Apps', 'Martin Kleppmann', 'Technical', 2017),
(4, 'The Data Model Resource Book', 'Len Silverston', 'Technical', 2001),
(4, 'The Data Model Resource Book', 'Paul Agnew', 'Technical', 2001);
