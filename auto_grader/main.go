package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "github.com/marcboeker/go-duckdb"
)

// Exercise represents a grading exercise configuration
type Exercise struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	SetupSQL    string  `json:"setup_sql,omitempty"`   // SQL to run before the exercise (create tables, insert data)
	SolutionSQL string  `json:"solution_sql"`          // Path to expected solution SQL file
	Checks      []Check `json:"checks"`                // Validation checks to run
}

// Check represents a validation check for an exercise
type Check struct {
	Name        string `json:"name"`
	Query       string `json:"query"`       // Query to run against the result
	Expected    string `json:"expected"`    // Expected result (JSON array of rows)
	Description string `json:"description"` // Human-readable description of what this checks
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
	case "grade-all":
		gradeAll()
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
	fmt.Println("  auto_grader grade-all            - Grade all exercises and print a summary")
	fmt.Println("  auto_grader list                 - List all available exercises")
	fmt.Println("  auto_grader help                 - Show this help message")
	fmt.Println()
	fmt.Println("Examples:")
	fmt.Println("  auto_grader grade ex01")
	fmt.Println("  auto_grader grade-all")
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

	result := runExercise(exercise)
	printResult(*exercise, result)
}

func gradeAll() {
	exercises, err := loadExercises()
	if err != nil {
		fmt.Printf("Error loading exercises: %v\n", err)
		os.Exit(1)
	}

	if len(exercises) == 0 {
		fmt.Println("No exercises found.")
		return
	}

	type summary struct {
		id         string
		name       string
		passed     bool
		noSolution bool
		checks     int
		passing    int
	}

	var results []summary
	totalPassed := 0

	fmt.Println("Running all exercises...")
	fmt.Println()

	for _, ex := range exercises {
		solutionPath := filepath.Join("solutions", ex.ID+".sql")
		if _, err := os.Stat(solutionPath); os.IsNotExist(err) {
			results = append(results, summary{
				id:         ex.ID,
				name:       ex.Name,
				noSolution: true,
			})
			continue
		}

		result := runExercise(&ex)
		passing := 0
		for _, cr := range result.Details {
			if cr.Passed {
				passing++
			}
		}
		results = append(results, summary{
			id:      ex.ID,
			name:    ex.Name,
			passed:  result.Passed,
			checks:  len(ex.Checks),
			passing: passing,
		})
		if result.Passed {
			totalPassed++
		}
	}

	fmt.Println("=== Results Summary ===")
	fmt.Println()
	for _, r := range results {
		if r.noSolution {
			fmt.Printf("⏭️  %s - %s (no solution file found)\n", r.id, r.name)
		} else if r.passed {
			fmt.Printf("✅ %s - %s (%d/%d checks)\n", r.id, r.name, r.passing, r.checks)
		} else {
			fmt.Printf("❌ %s - %s (%d/%d checks)\n", r.id, r.name, r.passing, r.checks)
		}
	}

	fmt.Println()
	fmt.Printf("Score: %d/%d exercises passed\n", totalPassed, len(exercises))
}

func runExercise(exercise *Exercise) GradeResult {
	result := GradeResult{
		ExerciseID: exercise.ID,
		Passed:     true,
		Details:    []CheckResult{},
	}

	// Check if user's solution file exists
	solutionPath := filepath.Join("solutions", exercise.ID+".sql")
	if _, err := os.Stat(solutionPath); os.IsNotExist(err) {
		result.Passed = false
		result.Message = fmt.Sprintf("Solution file not found: %s", solutionPath)
		return result
	}

	// Read user's solution
	userSolution, err := os.ReadFile(solutionPath)
	if err != nil {
		result.Passed = false
		result.Message = fmt.Sprintf("Error reading solution: %v", err)
		return result
	}

	// Create in-memory DuckDB database
	db, err := sql.Open("duckdb", "")
	if err != nil {
		result.Passed = false
		result.Message = fmt.Sprintf("Error creating database: %v", err)
		return result
	}
	defer db.Close()

	// Run setup SQL if provided
	if exercise.SetupSQL != "" {
		setupPath := filepath.Join("exercises", exercise.ID, exercise.SetupSQL)
		setupSQL, err := os.ReadFile(setupPath)
		if err != nil {
			result.Passed = false
			result.Message = fmt.Sprintf("Error reading setup SQL: %v", err)
			return result
		}
		if _, err := db.Exec(string(setupSQL)); err != nil {
			result.Passed = false
			result.Message = fmt.Sprintf("Error running setup SQL: %v", err)
			return result
		}
	}

	// Run user's solution
	if _, err := db.Exec(string(userSolution)); err != nil {
		result.Passed = false
		result.Message = fmt.Sprintf("Error in your SQL: %v", err)
		return result
	}

	// Run checks
	for _, check := range exercise.Checks {
		checkResult := runCheck(db, check)
		result.Details = append(result.Details, checkResult)
		if !checkResult.Passed {
			result.Passed = false
		}
	}

	return result
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

	// Parse expected JSON
	var expected []map[string]interface{}
	if err := json.Unmarshal([]byte(check.Expected), &expected); err != nil {
		return CheckResult{
			CheckName: check.Name,
			Passed:    false,
			Message:   fmt.Sprintf("Invalid expected JSON: %v", err),
		}
	}

	// Compare with tolerance-aware comparison
	gotJSON, _ := json.Marshal(results)
	expectedJSON, _ := json.Marshal(expected)

	if compareResults(results, expected) {
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

// compareResults compares two result sets with tolerance for numeric types.
// For numeric values, uses float64 comparison with a tolerance of 0.01.
// For strings and booleans, uses exact comparison.
func compareResults(got, expected []map[string]interface{}) bool {
	if len(got) != len(expected) {
		return false
	}

	for i := range got {
		gotRow := got[i]
		expRow := expected[i]

		// Column count must match
		if len(gotRow) != len(expRow) {
			return false
		}

		for key, expVal := range expRow {
			gotVal, ok := gotRow[key]
			if !ok {
				return false
			}
			if !compareValues(gotVal, expVal) {
				return false
			}
		}
	}
	return true
}

// compareValues compares two values, using numeric tolerance for numbers.
func compareValues(got, expected interface{}) bool {
	// Both nil
	if got == nil && expected == nil {
		return true
	}
	if got == nil || expected == nil {
		return false
	}

	// Try numeric comparison first
	gotF, gotIsNum := toFloat64(got)
	expF, expIsNum := toFloat64(expected)
	if gotIsNum && expIsNum {
		return math.Abs(gotF-expF) <= 0.01
	}

	// Boolean comparison
	gotB, gotIsBool := got.(bool)
	expB, expIsBool := expected.(bool)
	if gotIsBool && expIsBool {
		return gotB == expB
	}

	// String comparison (covers dates, strings, etc.)
	gotStr := fmt.Sprintf("%v", got)
	expStr := fmt.Sprintf("%v", expected)
	return gotStr == expStr
}

// toFloat64 attempts to convert a value to float64. Returns (value, true) on success.
func toFloat64(v interface{}) (float64, bool) {
	switch val := v.(type) {
	case float64:
		return val, true
	case float32:
		return float64(val), true
	case int:
		return float64(val), true
	case int8:
		return float64(val), true
	case int16:
		return float64(val), true
	case int32:
		return float64(val), true
	case int64:
		return float64(val), true
	case uint:
		return float64(val), true
	case uint8:
		return float64(val), true
	case uint16:
		return float64(val), true
	case uint32:
		return float64(val), true
	case uint64:
		return float64(val), true
	case json.Number:
		if f, err := val.Float64(); err == nil {
			return f, true
		}
	}
	return 0, false
}

func printResult(exercise Exercise, result GradeResult) {
	fmt.Printf("\n=== Grading: %s ===\n\n", exercise.Name)

	if result.Message != "" && len(result.Details) == 0 {
		fmt.Printf("❌ %s\n", result.Message)
		fmt.Println()
		return
	}

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

	// Sort by ID for consistent ordering
	sort.Slice(exercises, func(i, j int) bool {
		return exercises[i].ID < exercises[j].ID
	})

	return exercises, nil
}
