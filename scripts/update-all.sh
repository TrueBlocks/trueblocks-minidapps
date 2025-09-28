#!/bin/bash

# update-all - Update all submodules and Go modules
# Usage: update-all
# Called by: make update

set -e  # Exit on any error

echo "🔄 Comprehensive update: submodules + Go modules + workspace sync"
echo

# Store the original directory
ORIGINAL_DIR=$(pwd)

# Function to run commands in a directory
run_in_dir() {
    local dir="$1"
    local display_name="$2"
    shift 2  # Remove dir and display_name from arguments
    
    echo "=== $display_name ==="
    if [ -d "$dir" ]; then
        cd "$dir" || exit 1
        echo "📍 Working in: $dir"
        
        # Run each command passed as arguments
        for cmd in "$@"; do
            echo "🔧 Running: $cmd"
            eval "$cmd"
        done
        echo
    else
        echo "❌ Directory not found: $dir"
        echo
        return 1
    fi
}

# 1. Update git submodules
echo "🔄 Step 1: Updating Git submodules..."
cd "$ORIGINAL_DIR"
echo "🔧 Running: git submodule update --init --recursive"
git submodule update --init --recursive
echo "🔧 Running: git submodule update --remote --merge"
git submodule update --remote --merge
echo

# 2. Pull latest changes for each submodule
echo "🔄 Step 2: Pulling latest changes in each submodule..."
for submodule in $(git submodule foreach --quiet 'echo $path'); do
    submodule_path="$ORIGINAL_DIR/$submodule"
    run_in_dir "$submodule_path" "Submodule: $submodule" \
        "git pull origin \$(git rev-parse --abbrev-ref HEAD)"
done

# 3. Update Go modules in workspace and all directories with go.mod
echo "🔄 Step 3: Updating Go modules..."

# First, handle workspace sync if go.work exists
cd "$ORIGINAL_DIR"
if [ -f "go.work" ]; then
    echo "=== Root Workspace (pre-sync) ==="
    echo "📍 Working in: $ORIGINAL_DIR"
    echo "🔧 Running: go work sync"
    go work sync
    echo
fi

# Find all directories with go.mod files and tidy them
while IFS= read -r -d '' gomod_file; do
    gomod_dir=$(dirname "$gomod_file")
    relative_path=${gomod_dir#./}
    
    # Skip if it's the current directory (no go.mod in root)
    if [ "$gomod_dir" = "." ]; then
        continue
    fi
    
    # Use absolute path for directory
    abs_path="$ORIGINAL_DIR/$relative_path"
    run_in_dir "$abs_path" "Go Module: $relative_path" \
        "go mod tidy"
done < <(find . -name "go.mod" -type f -print0)

# 4. Final workspace sync
echo "🔄 Step 4: Final workspace synchronization..."
cd "$ORIGINAL_DIR"
if [ -f "go.work" ]; then
    echo "=== Final Workspace Sync ==="
    echo "📍 Working in: $ORIGINAL_DIR"
    echo "🔧 Running: go work sync"
    go work sync
    echo
fi

# 5. Show final status
echo "🔄 Step 5: Final status check..."
echo "=== Git Submodule Status ==="
git submodule status
echo

# Return to original directory
cd "$ORIGINAL_DIR"

echo "✅ Update complete!"
echo "📊 Summary:"
echo "   • Git submodules updated and pulled"
echo "   • All Go modules tidied"  
echo "   • Workspace synchronized"
echo "💡 Next steps: Run 'make check' to format, test, and build"
echo