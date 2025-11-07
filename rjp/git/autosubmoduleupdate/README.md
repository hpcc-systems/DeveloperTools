# Git Submodule Auto-Update Tool

Automatically update git submodules when switching branches to maintain consistent submodule state across your development workflow and prevent build corruption.

## 🎯 **Problem Solved**

When working with git repositories that contain submodules (like HPCC Platform with `esp/src/dgrid` and `vcpkg`), manually running `git submodule update --init --recursive` after every branch switch becomes tedious and error-prone. 

**⚠️ Critical for HPCC Platform**: Failing to update the `vcpkg` submodule when switching branches can lead to **serious build corruption**. Building with an outdated vcpkg hash can corrupt the vcpkg install/build process, requiring time-consuming cleanup and rebuilds. This tool prevents these costly issues by ensuring submodules are always synchronized with the current branch.

## 🚀 **Features**

- **Prevents vcpkg build corruption** by ensuring consistent package manager state
- **Automatic submodule updates** when checking out branches
- **Enhanced git submodule visibility** in status and diff commands
- **Team-wide consistency** through shared configuration
- **Smart detection** - only runs on branch checkouts, not file checkouts
- **Clear feedback** - shows when submodules are being updated

## 📋 **What's Included**

- `post-checkout` - Git hook that automatically runs submodule updates
- `install-hooks.sh` - Setup script for easy installation
- `README.md` - This documentation

## 🔧 **Installation**

### Quick Setup (Recommended)

```bash
# 1. Copy files to your repository's githooks directory
cp post-checkout /path/to/your/repo/githooks/
cp install-hooks.sh /path/to/your/repo/

# 2. Run the installation script
cd /path/to/your/repo
./install-hooks.sh
```

### Manual Setup

```bash
# 1. Copy the post-checkout hook
cp post-checkout /path/to/your/repo/.git/hooks/
chmod +x /path/to/your/repo/.git/hooks/post-checkout

# 2. Configure git for better submodule handling
git config submodule.recurse true
git config status.submoduleSummary true
git config diff.submodule log
```

## 💡 **Usage**

Once installed, the tool works transparently:

```bash
# Normal git workflow - submodules update automatically
git checkout feature-branch
# Output: Branch checkout detected. Updating submodules...
# Output: Submodules updated successfully.

git checkout main
# Output: Branch checkout detected. Updating submodules...
# Output: Submodules updated successfully.
```

## 🔍 **Enhanced Git Commands**

After installation, you'll also get enhanced git output:

```bash
# git status shows submodule summaries
git status
# Shows: * submodule-name abc1234...def5678 (2):
#          > Recent submodule commit message

# git diff shows submodule changes as commit ranges
git diff
# Shows: Submodule submodule-name abc1234..def5678:
#          < Old commit message
#          > New commit message
```

## ��️ **How It Works**

The `post-checkout` hook:
1. **Detects branch checkouts** (vs. file checkouts) using git hook parameters
2. **Runs `git submodule update --init --recursive`** to sync submodules
3. **Provides feedback** about the update process
4. **Exits with error codes** if submodule updates fail

## 📁 **File Descriptions**

### `post-checkout`
Git hook that automatically updates submodules when switching branches.
- **Trigger**: After successful `git checkout` of a branch
- **Action**: Runs `git submodule update --init --recursive`
- **Safety**: Only runs on branch checkouts, not file checkouts

### `install-hooks.sh`
Convenience script for team-wide deployment.
- Copies all hooks from `githooks/` to `.git/hooks/`
- Makes hooks executable
- Configures git for enhanced submodule handling
- Provides setup confirmation

## 🎛️ **Configuration Options**

The installation script sets these git configurations:

| Setting | Effect |
|---------|--------|
| `submodule.recurse true` | Git commands automatically recurse into submodules |
| `status.submoduleSummary true` | `git status` shows submodule change summaries |
| `diff.submodule log` | `git diff` shows submodule changes as commit ranges |

## ⚠️ **Important Notes**

- **vcpkg corruption prevention**: Essential for HPCC Platform builds to avoid package manager state corruption
- **Team deployment**: Each developer needs to run the installation script
- **Repository-specific**: Configuration is per-repository, not global
- **Backup existing hooks**: If you have existing git hooks, back them up first
- **Submodule conflicts**: If submodule updates fail, the hook will exit with an error

## 🔄 **Compatibility**

- **Git versions**: Compatible with Git 2.7+ (supports `submodule.recurse`)
- **Operating systems**: Linux, macOS, Windows (with Git Bash)
- **Repository types**: Any git repository with submodules

## 🐛 **Troubleshooting**

### Hook not executing
```bash
# Check if hook is executable
ls -la .git/hooks/post-checkout
# Should show: -rwxr-xr-x

# Make executable if needed
chmod +x .git/hooks/post-checkout
```

### Submodule update failures
```bash
# Check submodule status
git submodule status

# Manual update to diagnose issues
git submodule update --init --recursive
```

### vcpkg corruption recovery
```bash
# If vcpkg gets corrupted, clean and rebuild
rm -rf build/vcpkg_installed/ build/vcpkg_packages/
git submodule update --init --recursive
# Then rebuild your project
```

### Disable temporarily
```bash
# Rename hook to disable
mv .git/hooks/post-checkout .git/hooks/post-checkout.disabled

# Rename back to enable
mv .git/hooks/post-checkout.disabled .git/hooks/post-checkout
```

## 📚 **Examples**

### HPCC Platform Repository
This tool was originally developed for the HPCC Platform repository which has critical submodules:
- `esp/src/dgrid` - UI grid component
- `vcpkg` - C++ package manager (critical for build integrity)

### Typical Workflow with Build Safety
```bash
# Developer workflow with automatic submodule updates
git checkout main
# vcpkg submodule automatically updated to main's version - build safe!

git checkout HPCC-12345-new-feature  
# vcpkg submodule automatically updated to feature branch's version - no corruption!

# Build with confidence - vcpkg is synchronized
cmake --build build --parallel

git status
# Shows any submodule changes clearly

git diff
# Shows submodule changes as readable commit ranges
```

### Without This Tool (Problematic)
```bash
# Dangerous workflow without automatic updates
git checkout HPCC-12345-new-feature
# vcpkg submodule still points to old commit
cmake --build build --parallel
# 💥 Build corruption due to vcpkg version mismatch!
```

## 🤝 **Contributing**

To improve this tool:
1. Test with your repository setup
2. Submit issues for any problems encountered
3. Propose enhancements via pull requests

## 📄 **License**

This tool is part of the HPCC Systems DeveloperTools collection and follows the same license terms.

---

**Author**: RJP  
**Created**: November 2025  
**Purpose**: Streamline git submodule management and prevent vcpkg build corruption in HPCC Platform development

## 🏗️ **For HPCC-Platform Developers**

### One-Command Installation from DeveloperTools

If you have a local clone of the DeveloperTools repository, you can install this tool to your HPCC-Platform repository with a single command:

```bash
# From your DeveloperTools clone
cd DeveloperTools/rjp/git/autosubmoduleupdate
./install-to-hpcc-platform.sh
```

The installer will:
- 🔍 **Auto-detect** your HPCC-Platform repository in common locations:
  - `$HOME/GIT/HPCC-Platform`
  - `$HOME/git/HPCC-Platform` 
  - Same parent directory as DeveloperTools
  - And several other common paths
- ✅ **Verify** it's actually an HPCC-Platform repository
- 💾 **Backup** any existing git hooks
- 📦 **Install** the post-checkout hook and configuration
- 🎯 **Configure** git for enhanced submodule handling

### Manual Path Specification

If your HPCC-Platform is in a custom location:

```bash
cd DeveloperTools/rjp/git/autosubmoduleupdate
./install-to-hpcc-platform.sh /path/to/your/HPCC-Platform
```

### Verification

After installation, test that it works:

```bash
cd /path/to/your/HPCC-Platform
git checkout main
# Output: Branch checkout detected. Updating submodules...
# Output: Submodules updated successfully.
```

Now you're protected from vcpkg build corruption! 🛡️

