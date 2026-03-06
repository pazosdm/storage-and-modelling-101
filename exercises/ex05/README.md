# Exercise 05 – ER Design for a University System

## Overview

Design a database for a university course enrollment system from scratch. There is no existing data — you define the schema, constraints, and insert your own seed data.

## Requirements

- **Students** have: `student_id`, `name`, `enrollment_year`
- **Courses** have: `course_id`, `course_name`, `credits`
- **Professors** have: `professor_id`, `name`
- Each course is taught by exactly one professor
- Students can enroll in many courses; each course can have many students
- Each enrollment has a `grade` (nullable — assigned later)

## Tasks

1. Create tables: `students`, `professors`, `courses`, `enrollments`
2. Define appropriate `PRIMARY KEY`, `FOREIGN KEY`, and `NOT NULL` constraints
3. Insert the following seed data:
   - 3 students
   - 2 professors
   - 3 courses (each taught by one of the 2 professors)
   - 5 enrollments (students enrolled in courses, grade can be NULL)
4. Write a query that returns each student's name and total enrolled credits (you don't need to save this as a view, just write it in your solution file)

## What to Submit

Write your solution in `solutions/ex05.sql`.

## Hints

- `enrollments` is a junction table with `student_id` (FK) and `course_id` (FK) as its composite PK, plus a `grade` column.
- `courses` needs a `professor_id` FK column.
- DuckDB supports `FOREIGN KEY (col) REFERENCES table(col)` syntax in `CREATE TABLE`.
- To count total credits per student: `JOIN enrollments ON students.student_id = enrollments.student_id JOIN courses ON enrollments.course_id = courses.course_id` then `SUM(courses.credits)`.
