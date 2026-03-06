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

## Setup

### Option A — Local (Go required)

Install Go and DuckDB CLI via Homebrew:

```bash
make setup   # runs: brew install go duckdb
make build   # compiles the grader → ./grader
```

> **Note:** If you just installed Go and `make build` fails with "command not found", open a new terminal tab first. Homebrew updates your PATH on shell startup, so the current session won't see the new install until you restart it.

### Option B — Docker (no local installs needed)

If you don't want to install Go, Docker works out of the box. The image bundles the compiled grader and DuckDB. Your `solutions/` folder is mounted as a live volume, so edits you make locally are immediately visible inside the container.

```bash
# First time: build the image (takes ~2 min, downloads Go + DuckDB)
docker compose build

# Start an interactive shell inside the container
docker compose run --rm learn-duckdb bash

# Inside the container, use the grader normally:
grader list
grader grade ex01
grader grade-all
```

You **edit solution files on your machine** with your usual editor — the container picks up changes automatically because `solutions/` is mounted:

```
Your editor  →  solutions/ex01.sql  →  mounted into container  →  grader grades it
```

To grade a single exercise without opening a shell:

```bash
docker compose run --rm learn-duckdb grader grade ex01
```

## Quickstart (local)

```bash
# 1. Build the grader
make build

# 2. List all exercises
./grader list

# 3. Read an exercise
cat exercises/ex01/README.md

# 4. Write your solution (use your preferred editor)
code solutions/ex01.sql       # VS Code
cursor solutions/ex01.sql     # Cursor
open -a "TextEdit" solutions/ex01.sql  # macOS default

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

Solutions live in `solutions/`. The files are pre-created with a comment header — open one in your editor and write your SQL below the comment.

```bash
# Pick your editor:
code solutions/ex07.sql       # VS Code
cursor solutions/ex07.sql     # Cursor
open -a "TextEdit" solutions/ex07.sql  # macOS default
vim solutions/ex07.sql        # Vim
```

### Step 3 — Grade your work

```bash
./grader grade ex07
```

Example output:

```text
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

```text
=== Results Summary ===

✅ ex01 - Normalize a Wide Table to 3NF (4/4 checks)
✅ ex02 - Identify and Fix Anomalies (4/4 checks)
❌ ex03 - Normalize Reference Data with Deduplication (3/5 checks)
⏭️  ex04 - Normalization vs Query Complexity (no solution file found)
...

Score: 18/30 exercises passed
```

## Project Structure

```text
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
├── Dockerfile              # Builds grader + installs DuckDB in Alpine Linux
├── docker-compose.yml      # Mounts solutions/ and exercises/ as live volumes
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
