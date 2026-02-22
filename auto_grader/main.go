package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/marcboeker/go-duckdb"
)

// Exercise represents a grading exercise configuration
type Exercise struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	SetupSQL    string   `json:"setup_sql,omitempty"`    // SQL to run before the exercise (create tables, insert data)
	SolutionSQL string   `json:"solution_sql"`           // Path to expected solution SQL file
	Checks      []Check  `json:"checks"`                 // Validation checks to run
}

// Check represents a validation check for an exercise
type Check struct {
	Name        string `json:"name"`
	Query       string `json:"query"`        // Query to run against the result
	Expected    string `json:"expected"`     // Expected result (JSON array of rows)
	Description string `json:"description"`  // Human-readable description of what this checks
}

// GradeResult represents the result of grading an exercise
type GradeResult struct {
	ExerciseID string
	Passed     bool
	Message    string
	Details    []CheckResult
}

// CheckResult represents the result of a single check
type CheckResult struct {
	CheckName string
	Passed    bool
	Message   string
	Expected  string
	Got       string
}

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "grade":
		if len(os.Args) < 3 {
			fmt.Println("Error: exercise ID required")
			fmt.Println("Usage: auto_grader grade <exercise_id>")
			os.Exit(1)
		}
		exerciseID := os.Args[2]
		gradeExercise(exerciseID)
	case "list":
		listExercises()
	case "help":
		printUsage()
	default:
		fmt.Printf("Unknown command: %s\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("Storage & Modelling 101 - Auto Grader")
	fmt.Println()
	fmt.Println("Usage:")
	fmt.Println("  auto_grader grade <exercise_id>  - Grade your solution for an exercise")
	fmt.Println("  auto_grader list                 - List all available exercises")
	fmt.Println("  auto_grader help                 - Show this help message")
	fmt.Println()
	fmt.Println("Example:")
	fmt.Println("  auto_grader grade 01-create-table")
}

func listExercises() {
	exercises, err := loadExercises()
	if err != nil {
		fmt.Printf("Error loading exercises: %v\n", err)
		os.Exit(1)
	}

	if len(exercises) == 0 {
		fmt.Println("No exercises found.")
		fmt.Println("Exercises should be defined in exercises/*/config.json")
		return
	}

	fmt.Println("Available exercises:")
	fmt.Println()
	for _, ex := range exercises {
		fmt.Printf("  [%s] %s\n", ex.ID, ex.Name)
		fmt.Printf("      %s\n\n", ex.Description)
	}
}

func gradeExercise(exerciseID string) {
	exercise, err := loadExercise(exerciseID)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	// Check if user's solution file exists
	solutionPath := filepath.Join("solutions", exerciseID+".sql")
	if _, err := os.Stat(solutionPath); os.IsNotExist(err) {
		fmt.Printf("Error: Solution file not found: %s\n", solutionPath)
		fmt.Println()
		fmt.Printf("Create your solution at: %s\n", solutionPath)
		os.Exit(1)
	}

	// Read user's solution
	userSolution, err := os.ReadFile(solutionPath)
	if err != nil {
		fmt.Printf("Error reading solution: %v\n", err)
		os.Exit(1)
	}

	// Create in-memory DuckDB database
	db, err := sql.Open("duckdb", "")
	if err != nil {
		fmt.Printf("Error creating database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close()

	// Run setup SQL if provided
	if exercise.SetupSQL != "" {
		setupPath := filepath.Join("exercises", exerciseID, exercise.SetupSQL)
		setupSQL, err := os.ReadFile(setupPath)
		if err != nil {
			fmt.Printf("Error reading setup SQL: %v\n", err)
			os.Exit(1)
		}
		if _, err := db.Exec(string(setupSQL)); err != nil {
			fmt.Printf("Error running setup SQL: %v\n", err)
			os.Exit(1)
		}
	}

	// Run user's solution
	if _, err := db.Exec(string(userSolution)); err != nil {
		fmt.Printf("❌ Error in your SQL:\n")
		fmt.Printf("   %v\n", err)
		os.Exit(1)
	}

	// Run checks
	result := GradeResult{
		ExerciseID: exerciseID,
		Passed:     true,
		Details:    []CheckResult{},
	}

	for _, check := range exercise.Checks {
		checkResult := runCheck(db, check)
		result.Details = append(result.Details, checkResult)
		if !checkResult.Passed {
			result.Passed = false
		}
	}

	// Print results
	printResult(*exercise, result)
}

func runCheck(db *sql.DB, check Check) CheckResult {
	rows, err := db.Query(check.Query)
	if err != nil {
		return CheckResult{
			CheckName: check.Name,
			Passed:    false,
			Message:   fmt.Sprintf("Query error: %v", err),
		}
	}
	defer rows.Close()

	// Get column names
	columns, err := rows.Columns()
	if err != nil {
		return CheckResult{
			CheckName: check.Name,
			Passed:    false,
			Message:   fmt.Sprintf("Error getting columns: %v", err),
		}
	}

	// Collect results
	var results []map[string]interface{}
	for rows.Next() {
		values := make([]interface{}, len(columns))
		valuePtrs := make([]interface{}, len(columns))
		for i := range values {
			valuePtrs[i] = &values[i]
		}

		if err := rows.Scan(valuePtrs...); err != nil {
			return CheckResult{
				CheckName: check.Name,
				Passed:    false,
				Message:   fmt.Sprintf("Scan error: %v", err),
			}
		}

		row := make(map[string]interface{})
		for i, col := range columns {
			row[col] = values[i]
		}
		results = append(results, row)
	}

	// Compare with expected
	gotJSON, _ := json.Marshal(results)

	// Parse expected JSON
	var expected []map[string]interface{}
	if err := json.Unmarshal([]byte(check.Expected), &expected); err != nil {
		return CheckResult{
			CheckName: check.Name,
			Passed:    false,
			Message:   fmt.Sprintf("Invalid expected JSON: %v", err),
		}
	}

	// Simple comparison (could be made more sophisticated)
	expectedJSON, _ := json.Marshal(expected)

	if normalizeJSON(string(gotJSON)) == normalizeJSON(string(expectedJSON)) {
		return CheckResult{
			CheckName: check.Name,
			Passed:    true,
			Message:   "Passed!",
		}
	}

	return CheckResult{
		CheckName: check.Name,
		Passed:    false,
		Message:   check.Description,
		Expected:  string(expectedJSON),
		Got:       string(gotJSON),
	}
}

func normalizeJSON(s string) string {
	var v interface{}
	if err := json.Unmarshal([]byte(s), &v); err != nil {
		return s
	}
	normalized, _ := json.Marshal(v)
	return string(normalized)
}

func printResult(exercise Exercise, result GradeResult) {
	fmt.Printf("\n=== Grading: %s ===\n\n", exercise.Name)

	allPassed := true
	for _, check := range result.Details {
		if check.Passed {
			fmt.Printf("✅ %s\n", check.CheckName)
		} else {
			fmt.Printf("❌ %s\n", check.CheckName)
			fmt.Printf("   %s\n", check.Message)
			if check.Expected != "" {
				fmt.Printf("   Expected: %s\n", check.Expected)
				fmt.Printf("   Got:      %s\n", check.Got)
			}
			allPassed = false
		}
	}

	fmt.Println()
	if allPassed {
		fmt.Println("🎉 All checks passed! Great job!")
	} else {
		fmt.Println("Keep trying! Review the exercise requirements and update your solution.")
	}
}

func loadExercise(id string) (*Exercise, error) {
	configPath := filepath.Join("exercises", id, "config.json")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("exercise not found: %s", id)
	}

	var exercise Exercise
	if err := json.Unmarshal(data, &exercise); err != nil {
		return nil, fmt.Errorf("invalid exercise config: %v", err)
	}

	return &exercise, nil
}

func loadExercises() ([]Exercise, error) {
	exercisesDir := "exercises"
	entries, err := os.ReadDir(exercisesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return []Exercise{}, nil
		}
		return nil, err
	}

	var exercises []Exercise
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		if strings.HasPrefix(entry.Name(), ".") {
			continue
		}

		configPath := filepath.Join(exercisesDir, entry.Name(), "config.json")
		data, err := os.ReadFile(configPath)
		if err != nil {
			continue
		}

		var exercise Exercise
		if err := json.Unmarshal(data, &exercise); err != nil {
			continue
		}
		exercises = append(exercises, exercise)
	}

	return exercises, nil
}
