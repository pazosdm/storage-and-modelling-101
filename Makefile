.PHONY: setup build clean grade list help

BINARY := grader

# Default target
help:
	@echo "Storage & Modelling 101"
	@echo ""
	@echo "Usage:"
	@echo "  make setup    - Install dependencies (Go, DuckDB) via Homebrew"
	@echo "  make build    - Build the auto_grader"
	@echo "  make list     - List all exercises"
	@echo "  make grade ID=<exercise-id> - Grade an exercise"
	@echo "  make clean    - Remove build artifacts"
	@echo ""
	@echo "Example:"
	@echo "  make grade ID=01-create-table"

setup:
	@echo "Installing dependencies..."
	brew install go duckdb
	@echo "Done! Now run: make build"

build:
	@echo "Building auto_grader..."
	cd auto_grader && go build -o ../$(BINARY) .
	@echo "Done! Binary at ./$(BINARY)"

list: build
	./$(BINARY) list

grade: build
	@if [ -z "$(ID)" ]; then \
		echo "Error: ID required. Usage: make grade ID=01-create-table"; \
		exit 1; \
	fi
	./$(BINARY) grade $(ID)

clean:
	rm -f $(BINARY)
	rm -f data/*.duckdb data/*.duckdb.wal
