#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if profile is set
if [ ! -f "$PROJECT_ROOT/.profile" ]; then
    echo "❌ No profile set. Please run 'make profile <name>' first."
    exit 1
fi

# Read and export the current profile
PROFILE=$(cat "$PROJECT_ROOT/.profile")
export MACOS_CONFIG_PROFILE="$PROFILE"

# Set Homebrew environment variables to reduce noise
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1

# Export the full configuration flag if set
if [ "${MACOS_CONFIG_FULL}" = "1" ]; then
    export MACOS_CONFIG_FULL=1
    echo "Starting macOS configuration (FULL MODE - includes system-level settings)..."
    echo "Profile: $PROFILE"
else
    echo "Starting macOS configuration (DEFAULT MODE - no sudo commands)..."
    echo "Profile: $PROFILE"
    echo "Use 'make full' to enable system-level settings."
fi

# Run component scripts
echo "Running Homebrew setup..."
bash "$PROJECT_ROOT/components/brew.sh"

echo "Running Git configuration..."
bash "$PROJECT_ROOT/components/git.sh"

echo "Running Rust configuration..."
bash "$PROJECT_ROOT/components/rust.sh"

echo "Running Bun setup..."
bash "$PROJECT_ROOT/components/bun.sh"

echo "Running SurrealDB setup..."
bash "$PROJECT_ROOT/components/surreal.sh"

echo "Running macOS system configuration..."
bash "$PROJECT_ROOT/components/macos.sh"

echo "Running VSCode configuration..."
bash "$PROJECT_ROOT/components/vscode.sh"

echo "Running ZSH configuration..."
bash "$PROJECT_ROOT/components/zsh.sh"

# Run profile-specific setup
if [ "$MACOS_CONFIG_PROFILE" = "personal" ]; then
    echo "Running personal profile setup..."
    bash "$PROJECT_ROOT/components/personal.sh"
elif [ "$MACOS_CONFIG_PROFILE" = "work" ]; then
    echo "Running work profile setup..."
    # Add work.sh script if needed in the future
    echo "No additional work profile setup needed"
fi

echo "macOS configuration complete!"