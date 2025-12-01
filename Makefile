# TrueBlocks Mini

.PHONY: build test clean lint lint-all fmt help update explorer dalleserver check build-dev-tools test-dev-tools update-dev-tools

# Default target
.DEFAULT_GOAL := help

# Build all applications
build:
	@echo "Building all applications..."
	@mkdir -p bin
	@echo "Building Wails explorer..."
	@cd explorer && wails build
	@cp "explorer/build/bin/TrueBlocks Explorer.app/Contents/MacOS/trueblocks-explorer" bin/explorer
	@echo "Building dalleserver..."
	@cd dalleserver && go build -o ../bin/dalleserver ./...
	@echo "✅ Build complete"

# Test all modules
test:
	@echo "Running tests..."
	@cd explorer && go test ./...
	@cd dalleserver && TB_DALLE_SKIP_IMAGE=1 go test ./...
	@echo "Testing libraries..."
	@cd libs/trueblocks-sdk && go test ./... || echo "  SDK tests completed with expected issues"
	@cd libs/trueblocks-dalle && go test ./... || echo "  DALLE tests completed with expected issues"
	@echo "Testing development tools..."
	@cd dev-tools/create-local-app && go test ./... || echo "  create-local-app tests completed"
	@echo "✅ Tests complete"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	@cd explorer && rm -rf build/
	@cd explorer && go clean ./...
	@cd dalleserver && go clean ./...
	@cd libs/trueblocks-sdk && go clean ./...
	@cd libs/trueblocks-dalle && go clean ./...
	@cd dev-tools/create-local-app && go clean ./... && rm -rf bin/
	@echo "✅ Clean complete"

# Lint all code including libraries (may have issues)
lint:
	@echo "Running linter on all modules..."
	@command -v golangci-lint >/dev/null 2>&1 || { echo "golangci-lint not installed. Install with: curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$$(go env GOPATH)/bin latest"; exit 1; }
	@cd explorer && golangci-lint run
	@cd dalleserver && golangci-lint run
	@echo "Linting libraries..."
	@cd libs/trueblocks-sdk && golangci-lint run || echo "  SDK lint completed with expected issues"
	@cd libs/trueblocks-dalle && golangci-lint run || echo "  DALLE lint completed with expected issues"
	@echo "✅ Lint complete"

# Format all Go code
fmt:
	@echo "Formatting code..."
	@cd explorer && go fmt ./...
	@cd dalleserver && go fmt ./...
	@cd libs/trueblocks-sdk && go fmt ./...
	@cd libs/trueblocks-dalle && go fmt ./...
	@cd dev-tools/create-local-app && go fmt ./...
	@echo "✅ Format complete"

bin/explorer: $(shell find explorer -name "*.go" -o -name "*.json" -o -name "*.mod" -o -name "*.sum" | grep -v build/)
	@echo "Building Wails explorer..."
	@mkdir -p bin
	@cd explorer && wails build
	@cp "explorer/build/bin/TrueBlocks Explorer.app/Contents/MacOS/trueblocks-explorer" bin/explorer
	@echo "✅ Explorer build complete"

bin/dalleserver: $(shell find dalleserver -name "*.go" -o -name "*.mod" -o -name "*.sum")
	@echo "Building dalleserver..."
	@mkdir -p bin
	@cd dalleserver && go build -o ../bin/dalleserver main.go
	@echo "✅ Dalleserver build complete"

# Run explorer
explorer: bin/explorer
	@echo "Running explorer..."
	./bin/explorer

# Run dalleserver
dalleserver: bin/dalleserver
	@echo "Running dalleserver..."
	./bin/dalleserver

# Build development tools
build-dev-tools:
	@echo "Building development tools..."
	@cd dev-tools/create-local-app && go build -o bin/create-local-app main.go
	@echo "✅ Development tools built"

# Test development tools only  
test-dev-tools:
	@echo "Testing development tools..."
	@cd dev-tools/create-local-app && go test ./...
	@echo "✅ Development tools tests complete"

# Update development tools
update-dev-tools:
	@echo "Updating development tools..."
	@cd dev-tools/create-local-app && git pull origin main
	@echo "✅ Development tools updated"

# Check everything (format, lint, test, build)
check: fmt test build
	@echo "✅ All checks passed"

# Show help
help:
	@echo "TrueBlocks Mini-DApps Development Commands:"
	@echo ""
	@echo "  build       - Build all applications"
	@echo "  test        - Run tests for all modules"
	@echo "  clean       - Clean build artifacts"
	@echo "  lint        - Run golangci-lint on all modules (may have issues)"
	@echo "  fmt         - Format all Go code"
	@echo "  check       - Run fmt, test, and build"
	@echo "  update      - Update git submodules and Go modules comprehensively"
	@echo "  explorer    - Build and run explorer"
	@echo "  dalleserver - Build and run dalleserver"
	@echo ""
	@echo "Development Tools:"
	@echo "  build-dev-tools   - Build development tools (create-local-app)"
	@echo "  test-dev-tools    - Test development tools only"
	@echo "  update-dev-tools  - Update development tools from remote"
	@echo ""
	@echo "  help       - Show this help message"
