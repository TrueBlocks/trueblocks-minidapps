# Quick Start Guide

## Initial Setup

```bash
git clone --recursive https://github.com/TrueBlocks/trueblocks-minidapps.git
cd trueblocks-minidapps
make check
```

## Daily Development Commands

```bash
make build      # Build all apps
make test       # Run tests 
make fmt        # Format code
make lint       # Run linter (requires golangci-lint)
make run-app1   # Run testapp1
make run-app2   # Run testapp2
make clean      # Clean artifacts
make help       # Show all commands
```

## Add New Application

```bash
mkdir newapp
cd newapp
go mod init github.com/TrueBlocks/newapp/v2
go mod edit -go=1.25.1
# Add "use ./newapp" to go.work
```

## Release Process

```bash
git tag v2.1.0
git push origin v2.1.0
# GitHub Actions automatically creates release
```

## Troubleshooting

- **Slow VS Code**: Restart language server
- **Submodule issues**: `make update-libs`
- **Workspace sync**: `go work sync`
