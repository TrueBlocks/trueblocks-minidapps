# TrueBlocks Mini-DApps

A mono-repository for TrueBlocks mini-applications with shared libraries.

## Repository Structure

```text
trueblocks-minidapps/
├── libs/                     # Shared libraries as git submodules
│   ├── trueblocks-sdk/      # Core SDK library (v5)
│   └── trueblocks-dalle/    # DALL-E integration library (v2)
├── testapp1/                # Example application 1
├── testapp2/                # Example application 2
├── bin/                     # Built binaries (created by make build)
├── .github/workflows/       # CI/CD workflows
├── go.work                  # Go workspace configuration
└── Makefile                 # Build and development commands
```

## Quick Start

### Prerequisites

- Go 1.25.1 or later
- Git with submodule support
- (Optional) golangci-lint for linting

### Setup

1. Clone the repository with submodules:

   ```bash
   git clone --recursive https://github.com/TrueBlocks/trueblocks-minidapps.git
   cd trueblocks-minidapps
   ```

2. If you already cloned without `--recursive`:

   ```bash
   git submodule update --init --recursive
   ```

3. Verify setup:

   ```bash
   make check
   ```

## Development Workflow

### Building and Testing

```bash
# Build all applications
make build

# Run tests across all modules
make test

# Format code
make fmt

# Lint code (requires golangci-lint)
make lint

# Run specific app
make run-app1
make run-app2

# Clean build artifacts
make clean
```

### Managing Dependencies

```bash
# Update git submodules to latest versions
make update-libs

# Update Go dependencies in all modules
cd libs/trueblocks-sdk && go get -u ./...
cd libs/trueblocks-dalle && go get -u ./...
cd testapp1 && go get -u ./...
cd testapp2 && go get -u ./...
```

### Adding New Applications

1. Create a new directory for your app:

   ```bash
   mkdir myapp
   cd myapp
   ```

2. Initialize Go module with /v2 versioning:

   ```bash
   go mod init github.com/TrueBlocks/myapp/v2
   go mod edit -go=1.25.1
   ```

3. Add to workspace:

   ```bash
   # Edit go.work and add:
   use ./myapp
   ```

4. Create your application and import shared libraries:

   ```go
   import (
       "github.com/TrueBlocks/trueblocks-sdk/v5/pkg/base"
       "github.com/TrueBlocks/trueblocks-dalle/v2/pkg/dalle"
   )
   ```

## Versioning Strategy

- **Repository**: Uses `/v2` for the main repo
- **Applications**: Each app uses `/v2` versioning (github.com/TrueBlocks/appname/v2)
- **Libraries**:
  - trueblocks-sdk uses `/v5`
  - trueblocks-dalle uses `/v2`

## CI/CD Pipeline

### Continuous Integration

The CI pipeline runs on every push and pull request:

1. **Format Check**: Ensures code is properly formatted
2. **Lint**: Runs golangci-lint for code quality
3. **Test**: Executes all tests across the workspace
4. **Build**: Compiles all applications
5. **Artifacts**: Uploads built binaries

### Releases

- Tag your code with `v*` pattern (e.g., `v2.1.0`)
- GitHub Actions automatically creates a release with binaries
- Release notes are auto-generated from commits

### Dependency Updates

- Dependabot automatically creates PRs for:
  - Go module updates (weekly)
  - GitHub Actions updates (weekly)
  - Git submodule updates (weekly)

## VS Code Configuration

The repository includes optimized VS Code settings for large workspaces:

- Faster gopls performance
- Reduced memory usage
- Optimized for 600+ dependencies

## Common Tasks

### Updating Submodules

```bash
# Update to latest commits
git submodule update --remote

# Or use the Makefile
make update-libs
```

### Creating a Release

```bash
# Tag the current commit
git tag v2.1.0
git push origin v2.1.0

# GitHub Actions will automatically create the release
```

### Troubleshooting

#### Slow VS Code Performance

- VS Code settings are pre-configured for performance
- Restart VS Code if gopls becomes unresponsive
- Use `Go: Restart Language Server` command if needed

#### Submodule Issues

```bash
# Reset submodules to clean state
git submodule deinit --all
git submodule update --init --recursive
```

#### Go Workspace Issues

```bash
# Verify workspace configuration
go work status

# Sync workspace
go work sync
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `make check` to verify everything works
4. Submit a pull request

The CI pipeline will automatically test your changes across all supported environments.
