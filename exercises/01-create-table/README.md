# Exercise 01: Create a Table

## Objective

Learn how to create a basic table in DuckDB with appropriate data types.

## Task

Create a table called `users` with the following columns:

| Column     | Type         | Constraints  |
|------------|--------------|--------------|
| id         | INTEGER      | PRIMARY KEY  |
| username   | VARCHAR(50)  | NOT NULL     |
| email      | VARCHAR(100) | NOT NULL     |
| created_at | TIMESTAMP    | NOT NULL     |

## Instructions

1. Create your solution file at: `solutions/01-create-table.sql`
2. Write the SQL to create the `users` table
3. Run the grader to check your solution:

```bash
./grader grade 01-create-table
```

## Hints

- Use `CREATE TABLE` statement
- DuckDB supports standard SQL data types
- Remember to add the PRIMARY KEY constraint

## Resources

- [DuckDB CREATE TABLE documentation](https://duckdb.org/docs/sql/statements/create_table)
