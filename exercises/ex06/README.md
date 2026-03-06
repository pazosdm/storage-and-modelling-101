# Exercise 06 – Resolve Many-to-Many Relationships

## Overview

The `raw_book_authors` table mixes book metadata and author names in a flat structure, with multiple rows per book when it has multiple authors. This is a classic many-to-many relationship that needs a junction table.

## Seed Data

```sql
CREATE TABLE raw_book_authors (
    book_id     INTEGER,
    book_title  VARCHAR,
    author_name VARCHAR,
    genre       VARCHAR,
    pub_year    INTEGER
);
-- 6 rows: books 1 and 4 each have 2 authors, books 2 and 3 have 1 each
```

## Tasks

1. Create normalized tables:
   - `authors` (author_id, author_name) — use `ROW_NUMBER()` for surrogate key
   - `books` (book_id, book_title, genre, pub_year)
   - `book_authors` (book_id, author_id) — junction table

2. Generate `author_id` as a surrogate key using `ROW_NUMBER()`.

3. Populate all three tables from `raw_book_authors`.

4. Write a query that returns each author and the number of books they co-authored (just write it in your solution — it doesn't need to be a view).

## What to Submit

Write your solution in `solutions/ex06.sql`.

## Hints

- Use a CTE to build unique authors: `WITH unique_authors AS (SELECT DISTINCT author_name FROM raw_book_authors)` then `SELECT ROW_NUMBER() OVER () AS author_id, author_name FROM unique_authors`.
- For `books`, use `SELECT DISTINCT book_id, book_title, genre, pub_year FROM raw_book_authors`.
- For `book_authors`, join back to the `authors` table to get `author_id`.
