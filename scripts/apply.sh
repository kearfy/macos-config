#!/bin/bash

# Handle interrupt signals (Ctrl+C) to exit cleanly
trap 'echo ""; echo "❌ Configuration interrupted by user. Exiting..."; exit 130' INT TERM

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if profile is set
if [ ! -f "$PROJECT_ROOT/.profile" ]; then
    echo "❌ No profile set. Running initial setup..."
    echo ""
    bash "$SCRIPT_DIR/init.sh"
    echo ""
    # Check again after init
    if [ ! -f "$PROJECT_ROOT/.profile" ]; then
        echo "❌ Setup was not completed. Exiting."
        exit 1
    fi
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
    echo "🚀 Starting macOS configuration (FULL MODE - includes system-level settings)"
    echo "📋 Profile: $PROFILE"
else
    echo "🚀 Starting macOS configuration (DEFAULT MODE - no sudo commands)"
    echo "📋 Profile: $PROFILE"
    echo "💡 Use 'make full' to enable system-level settings"
fi

echo ""
echo "================================================================================================"
echo ""

# Run component scripts
echo "📦 HOMEBREW SETUP"
echo "──────────────────"
bash "$PROJECT_ROOT/components/brew.sh"

echo ""
echo "🔧 GIT CONFIGURATION"
echo "─────────────────────"
bash "$PROJECT_ROOT/components/git.sh"

echo ""
echo "🦀 RUST SETUP"
echo "──────────────"
bash "$PROJECT_ROOT/components/rust.sh"

echo ""
echo "🍞 BUN SETUP"
echo "─────────────"
bash "$PROJECT_ROOT/components/bun.sh"

echo ""
echo "🗄️  SURREALDB SETUP"
echo "────────────────────"
bash "$PROJECT_ROOT/components/surreal.sh"

echo ""
echo "🍎 MACOS SYSTEM CONFIGURATION"
echo "──────────────────────────────"
bash "$PROJECT_ROOT/components/macos.sh"

echo ""
echo "🖼️  WALLPAPER SETUP"
echo "────────────────────"
bash "$PROJECT_ROOT/components/wallpaper.sh"

echo ""
echo "💻 VSCODE CONFIGURATION"
echo "────────────────────────"
bash "$PROJECT_ROOT/components/vscode.sh"

echo ""
echo "🐚 ZSH CONFIGURATION"
echo "─────────────────────"
bash "$PROJECT_ROOT/components/zsh.sh"

echo ""
echo "👤 PROFILE-SPECIFIC SETUP"
echo "──────────────────────────"
if [ "$MACOS_CONFIG_PROFILE" = "personal" ]; then
    echo "Running personal profile setup..."
    bash "$PROJECT_ROOT/components/personal.sh"
elif [ "$MACOS_CONFIG_PROFILE" = "work" ]; then
    echo "Running work profile setup..."
    # Add work.sh script if needed in the future
    echo "No additional work profile setup needed"
fi

echo ""
echo "================================================================================================"
echo ""
echo "✅ macOS configuration complete!"
echo ""
echo "🔄 Next steps:"
echo "   • Restart your terminal for ZSH changes to take effect"
echo "   • Some system settings may require a restart"
echo "   • Check 'make status' to verify your configuration"