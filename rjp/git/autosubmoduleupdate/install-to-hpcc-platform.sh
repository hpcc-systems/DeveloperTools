#!/bin/bash
#
# Install Git Submodule Auto-Update Tool to HPCC-Platform Repository
# 
# This script installs the git hooks from DeveloperTools to your local
# HPCC-Platform repository to prevent vcpkg build corruption.
#
# Usage:
#   ./install-to-hpcc-platform.sh [path-to-hpcc-platform]
#
# If no path is provided, it will look for HPCC-Platform in common locations.
#

set -e  # Exit on any error

echo "🚀 HPCC-Platform Git Submodule Auto-Update Installer"
echo "   Prevents vcpkg build corruption by auto-updating submodules"
echo "================================================================"
echo

# Function to check if a directory is an HPCC-Platform repository
is_hpcc_platform() {
    local dir="$1"
    if [ -d "$dir/.git" ] && [ -f "$dir/CMakeLists.txt" ] && [ -d "$dir/esp" ] && [ -d "$dir/vcpkg" ]; then
        return 0
    fi
    return 1
}

# Function to find HPCC-Platform repository
find_hpcc_platform() {
    local search_paths=(
        "../../../HPCC-Platform"           # Same parent as DeveloperTools
        "../../HPCC-Platform"              # One level up
        "../HPCC-Platform"                 # Sibling directory
        "$HOME/GIT/HPCC-Platform"          # Common git directory
        "$HOME/git/HPCC-Platform"          # Lowercase variant
        "$HOME/repos/HPCC-Platform"        # Alternative structure
        "$HOME/workspace/HPCC-Platform"    # IDE workspace
        "./HPCC-Platform"                  # Current directory
    )
    
    for path in "${search_paths[@]}"; do
        if is_hpcc_platform "$path"; then
            echo "$(cd "$path" && pwd)"
            return 0
        fi
    done
    return 1
}

# Get the script directory (where the hook files are located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 DeveloperTools location: $SCRIPT_DIR"

# Check if required files exist
if [ ! -f "$SCRIPT_DIR/post-checkout" ]; then
    echo "❌ Error: post-checkout hook not found in $SCRIPT_DIR"
    echo "   Make sure you're running this from the DeveloperTools/rjp/git/autosubmoduleupdate directory"
    exit 1
fi

# Determine HPCC-Platform path
HPCC_PATH=""
if [ $# -eq 1 ]; then
    # User provided path
    HPCC_PATH="$1"
    if [ ! -d "$HPCC_PATH" ]; then
        echo "❌ Error: Directory '$HPCC_PATH' does not exist"
        exit 1
    fi
    HPCC_PATH="$(cd "$HPCC_PATH" && pwd)"  # Convert to absolute path
else
    # Auto-detect HPCC-Platform
    echo "🔍 Searching for HPCC-Platform repository..."
    HPCC_PATH=$(find_hpcc_platform)
    if [ $? -ne 0 ]; then
        echo "❌ Error: Could not find HPCC-Platform repository"
        echo ""
        echo "Please provide the path to your HPCC-Platform repository:"
        echo "   $0 /path/to/HPCC-Platform"
        echo ""
        echo "Or ensure HPCC-Platform is in one of these locations:"
        echo "   - Same parent directory as DeveloperTools"
        echo "   - \$HOME/GIT/HPCC-Platform"
        echo "   - \$HOME/git/HPCC-Platform"
        exit 1
    fi
fi

# Verify it's actually HPCC-Platform
if ! is_hpcc_platform "$HPCC_PATH"; then
    echo "❌ Error: '$HPCC_PATH' does not appear to be an HPCC-Platform repository"
    echo "   Expected: .git directory, CMakeLists.txt, esp/, and vcpkg/ subdirectories"
    exit 1
fi

echo "✅ Found HPCC-Platform: $HPCC_PATH"
echo

# Check if there are existing git hooks and warn user
if [ -f "$HPCC_PATH/.git/hooks/post-checkout" ]; then
    echo "⚠️  Warning: Existing post-checkout hook found"
    echo "   Current hook will be backed up as post-checkout.backup"
    cp "$HPCC_PATH/.git/hooks/post-checkout" "$HPCC_PATH/.git/hooks/post-checkout.backup"
    echo "   ✓ Backup created: $HPCC_PATH/.git/hooks/post-checkout.backup"
fi

# Create githooks directory in HPCC-Platform if it doesn't exist
echo "📁 Setting up githooks directory..."
mkdir -p "$HPCC_PATH/githooks"

# Copy the post-checkout hook to githooks (for version control)
echo "📋 Installing post-checkout hook..."
cp "$SCRIPT_DIR/post-checkout" "$HPCC_PATH/githooks/"
cp "$SCRIPT_DIR/post-checkout" "$HPCC_PATH/.git/hooks/"

# Make sure the hook is executable
chmod +x "$HPCC_PATH/.git/hooks/post-checkout"
chmod +x "$HPCC_PATH/githooks/post-checkout"

# Configure git for better submodule handling
echo "⚙️  Configuring git settings for submodule management..."
cd "$HPCC_PATH"
git config submodule.recurse true
git config status.submoduleSummary true
git config diff.submodule log

echo
echo "🎉 Installation successful!"
echo "================================================================"
echo "✅ Git Submodule Auto-Update Tool installed to HPCC-Platform"
echo "✅ vcpkg build corruption prevention is now active"
echo "✅ Enhanced submodule status and diff display enabled"
echo
echo "🔧 What was installed:"
echo "   • $HPCC_PATH/.git/hooks/post-checkout"
echo "   • $HPCC_PATH/githooks/post-checkout (for version control)"
echo "   • Git configuration for submodule.recurse, status, and diff"
echo
echo "💡 Test the installation:"
echo "   cd '$HPCC_PATH'"
echo "   git checkout <different-branch>"
echo "   # Should see: 'Branch checkout detected. Updating submodules...'"
echo
echo "🛡️  Protection active: vcpkg will automatically stay synchronized"
echo "    No more build corruption from outdated package manager state!"
