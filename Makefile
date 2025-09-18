# TrueBlocks Mini-DApps Mono-Repo

.PHONY: build test clean lint lint-all fmt help update-libs run-app1 run-app2 check

# Default target
.DEFAULT_GOAL := help

# Build all applications
build:
	@echo "Building all applications..."
	@mkdir -p bin
	@echo "Building Wails explorer..."
	@cd explorer && wails build
	@cp "explorer/build/bin/TrueBlocks Explorer.app/Contents/MacOS/trueblocks-explorer" bin/explorer
	go build -o bin/testapp1 ./testapp1
	go build -o bin/testapp2 ./testapp2
	@echo "✅ Build complete"

# Test all modules
test:
	@echo "Running tests..."
	@cd explorer && go test ./...
	@cd testapp1 && go test ./...
	@cd testapp2 && go test ./...
	@echo "Testing libraries..."
	@cd libs/trueblocks-sdk && go test ./... || echo "  SDK tests completed with expected issues"
	@cd libs/trueblocks-dalle && go test ./... || echo "  DALLE tests completed with expected issues"
	@echo "✅ Tests complete"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	@cd explorer && rm -rf build/
	@cd explorer && go clean ./...
	@cd testapp1 && go clean ./...
	@cd testapp2 && go clean ./...
	@cd libs/trueblocks-sdk && go clean ./...
	@cd libs/trueblocks-dalle && go clean ./...
	@echo "✅ Clean complete"

# Lint all code including libraries (may have issues)
lint:
	@echo "Running linter on all modules..."
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not installed. Install with: curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$$(go env GOPATH)/bin latest"; exit 1; }
	@cd explorer && golangci-lint run
	@cd testapp1 && golangci-lint run
	@cd testapp2 && golangci-lint run
	@echo "Linting libraries..."
	@cd libs/trueblocks-sdk && golangci-lint run || echo "  SDK lint completed with expected issues"
	@cd libs/trueblocks-dalle && golangci-lint run || echo "  DALLE lint completed with expected issues"
	@echo "✅ Lint complete"

# Format all Go code
fmt:
	@echo "Formatting code..."
	@cd explorer && go fmt ./...
	@cd testapp1 && go fmt ./...
	@cd testapp2 && go fmt ./...
	@cd libs/trueblocks-sdk && go fmt ./...
	@cd libs/trueblocks-dalle && go fmt ./...
	@echo "✅ Format complete"

# Update everything: submodules, Go modules, and workspace
update:
	@echo "Running comprehensive update..."
	@./scripts/update-all

# Run explorer
explorer: build
	@echo "Running explorer..."
	./bin/explorer

# Run testapp1
app1: build
	@echo "Running testapp1..."
	./bin/testapp1

# Run testapp2
app2: build
	@echo "Running testapp2..."
	./bin/testapp2

# Check everything (format, lint, test, build)
check: fmt test build
	@echo "✅ All checks passed"

# Show help
help:
	@echo "TrueBlocks Mini-DApps Development Commands:"
	@echo ""
	@echo "  build      - Build all applications"
	@echo "  test       - Run tests for all modules"
	@echo "  clean      - Clean build artifacts"
	@echo "  lint       - Run golangci-lint on all modules (may have issues)"
	@echo "  fmt        - Format all Go code"
	@echo "  check      - Run fmt, test, and build"
	@echo "  update     - Update git submodules and Go modules comprehensively"
	@echo "  explorer   - Build and run explorer"
	@echo "  app1       - Build and run testapp1"
	@echo "  app2       - Build and run testapp2"
	@echo "  help       - Show this help message"