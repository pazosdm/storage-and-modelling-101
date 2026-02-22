# Storage & Modelling 101

Learn data storage and modelling concepts using DuckDB.

## Setup

```bash
make setup   # Installs Go and DuckDB via Homebrew
make build   # Builds the grader
```

## How to Use

1. List available exercises:

```bash
./grader list
```

2. Read the exercise instructions:

```bash
cat exercises/01-create-table/README.md
```

3. Create your SQL solution:

```bash
vim solutions/01-create-table.sql
```

4. Check your solution:

```bash
./grader grade 01-create-table
```

## Experimenting with DuckDB

You can use the DuckDB CLI directly to test queries:

```bash
duckdb
```

## Project Structure

```
exercises/          # Exercise instructions and grading config
solutions/          # Your SQL solutions go here
auto_grader/        # Grader source code (Go)
```
