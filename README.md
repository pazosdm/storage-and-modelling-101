# Storage & Modelling 101

A hands-on learning platform for data engineers (junior to senior) to practice **data modeling** and **data storage** concepts using DuckDB. Write SQL solutions, run them against a real in-memory database, and get instant pass/fail feedback.

## What You'll Learn

30 exercises covering:

| Section | Exercises | Topics |
|---------|-----------|--------|
| 1 | ex01–ex04 | Normalization, 1NF/2NF/3NF, anomalies |
| 2 | ex05–ex06 | ER modeling, many-to-many relationships |
| 3 | ex07–ex10 | Star schema, denormalization, OBT, summary tables |
| 4 | ex11–ex15 | Dimensional modeling, SCD1, SCD2, bridge tables, factless facts |
| 5 | ex16–ex18 | Data Vault, conformed dimensions, Inmon vs Kimball |
| 6 | ex19–ex20 | Semi-structured data, JSON extraction, array flattening |
| 7 | ex21–ex23 | File formats (CSV, Parquet, JSON), compression |
| 8 | ex24–ex26 | Data lifecycle, CDC, ACID transactions |
| 9 | ex27–ex28 | Indexes, columnar scan optimization |
| 10 | ex29–ex30 | Data contracts, schema constraints, quality metrics |

## Prerequisites

- **Go** 1.21+ — [golang.org/doc/install](https://golang.org/doc/install)
- **DuckDB CLI** (optional, for manual testing)

Install both with Homebrew:

```bash
make setup
```

## Quickstart

```bash
# 1. Build the grader
make build

# 2. List all exercises
./grader list

# 3. Read an exercise
cat exercises/ex01/README.md

# 4. Write your solution
vim solutions/ex01.sql

# 5. Grade your solution
./grader grade ex01

# 6. Run all exercises
./grader grade-all
```

## Workflow

### Step 1 — Read the exercise

Each exercise has a `README.md` explaining the seed data, your tasks, and what to build:

```bash
cat exercises/ex07/README.md
```

### Step 2 — Write your solution

Solutions live in `solutions/`. The files are pre-created with a comment header:

```bash
# Open in your editor
vim solutions/ex07.sql
```

### Step 3 — Grade your work

```bash
./grader grade ex07
```

Example output:
```
=== Grading: Build a Star Schema from 3NF ===

✅ fact_sales has 6 rows
✅ Total revenue matches
❌ dim_date covers Jan-Feb 2025
   Expected: [{"n":59}]
   Got:      [{"n":31}]

Keep trying! Review the exercise requirements and update your solution.
```

### Step 4 — Grade everything

Once you've worked through the exercises:

```bash
./grader grade-all
```

Example output:
```
=== Results Summary ===

✅ ex01 - Normalize a Wide Table to 3NF (4/4 checks)
✅ ex02 - Identify and Fix Anomalies (4/4 checks)
❌ ex03 - Normalize Reference Data with Deduplication (3/5 checks)
⏭️  ex04 - Normalization vs Query Complexity (no solution file found)
...

Score: 18/30 exercises passed
```

## Project Structure

```
.
├── exercises/              # Exercise definitions (read-only)
│   ├── ex01/
│   │   ├── config.json     # Grading checks and expected outputs
│   │   ├── seed.sql        # Setup data loaded before your solution runs
│   │   └── README.md       # Exercise description and tasks
│   ├── ex02/ ...
│   └── ex30/
│
├── solutions/              # Your SQL solutions go here
│   ├── ex01.sql            # Write your answer here
│   ├── ex02.sql
│   └── ...
│
├── auto_grader/            # Grader source (Go)
│   ├── main.go
│   ├── go.mod
│   └── go.sum
│
└── Makefile
```

## How Grading Works

For each exercise, the grader:

1. Opens a fresh **in-memory DuckDB** instance
2. Runs `seed.sql` to set up the tables and data
3. Runs **your solution** SQL
4. Executes a set of validation queries (`config.json` checks)
5. Compares the output against expected values

Numeric comparisons use a tolerance of ±0.01 to handle decimal rounding differences.

## Suggested Learning Path

- **Beginners** — Start with ex01–ex04 (normalization fundamentals)
- **Intermediate** — Work through ex05–ex13 (ER modeling, star schemas, SCDs)
- **Advanced** — Tackle ex14–ex30 (Data Vault, JSON, file formats, CDC, indexes)

## Manual DuckDB Testing

You can use the DuckDB CLI to test queries interactively:

```bash
duckdb
-- Paste your seed SQL, then experiment
```

Or run a specific exercise seed directly:

```bash
duckdb < exercises/ex01/seed.sql
```
