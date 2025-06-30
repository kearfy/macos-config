#!/bin/bash

# macOS Configuration Adoption Script
# This script clones the repository and sets up the initial configuration
# Usage: bash <(curl -s https://raw.githubusercontent.com/kearfy/macos-config/main/scripts/adopt.sh)

set -e  # Exit on any error

# Configuration
REPO_URL="https://github.com/kearfy/macos-config.git"
TARGET_DIR="$HOME/Repositories/Personal/macos-config"

echo "🚀 Welcome to macOS Configuration Adoption!"
echo ""
echo "This script will:"
echo "  1. Clone the macOS configuration repository"
echo "  2. Set up the directory structure"
echo "  3. Run the initial configuration"
echo "  4. Optionally apply the configuration"
echo ""

# Check if directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory already exists: $TARGET_DIR"
    echo ""
    read -p "Do you want to remove it and start fresh? (y/N): " remove_existing
    if [[ "$remove_existing" =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing directory..."
        rm -rf "$TARGET_DIR"
    else
        echo "❌ Aborted. Please remove or backup the existing directory first."
        exit 1
    fi
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first:"
    echo "   You can install it via Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "📁 Creating directory structure..."
mkdir -p "$(dirname "$TARGET_DIR")"

echo "📦 Cloning repository..."
git clone "$REPO_URL" "$TARGET_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Failed to clone repository"
    exit 1
fi

echo "✅ Repository cloned successfully!"
echo ""

# Change to the project directory
cd "$TARGET_DIR"

echo "🔧 Running initial configuration..."
echo ""

# Make scripts executable
chmod +x scripts/*.sh

# Run the initialization script
bash scripts/init.sh

echo ""
echo "🤔 Configuration Setup Complete!"
echo ""

# Ask if user wants to apply configuration now
read -p "Do you want to apply the configuration now? (Y/n): " apply_now
if [[ ! "$apply_now" =~ ^[Nn]$ ]]; then
    echo ""
    echo "🎯 Applying configuration..."
    echo ""
    
    # Ask for full or default mode
    echo "Choose application mode:"
    echo "  1) Default mode (no system-level changes, no sudo required)"
    echo "  2) Full mode (includes system-level settings, requires sudo)"
    echo ""
    
    while true; do
        read -p "Select mode (1 or 2): " mode_choice
        case $mode_choice in
            1)
                echo ""
                echo "🔄 Applying configuration in default mode..."
                make apply
                break
                ;;
            2)
                echo ""
                echo "🔄 Applying configuration in full mode..."
                echo "This will require administrator privileges."
                make full
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
    
    echo ""
    echo "🎉 Configuration applied successfully!"
else
    echo ""
    echo "⏭️  Configuration skipped."
    echo ""
    echo "To apply the configuration later, run:"
    echo "  cd $TARGET_DIR"
    echo "  make apply    # Default mode (no sudo)"
    echo "  make full     # Full mode (requires sudo)"
fi

echo ""
echo "📖 Useful commands:"
echo "  cd $TARGET_DIR"
echo "  make help           # Show available commands"
echo "  make status         # Check configuration status"
echo "  make profile <name> # Change profile (personal/work)"
echo "  make wallpaper <n>  # Change wallpaper"
echo ""
echo "🏁 Setup complete! Enjoy your configured macOS environment!"
