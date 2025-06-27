#!/bin/bash

echo "Configuring iTerm2..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if iTerm2 app is installed
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "iTerm2 is not installed. Please run 'brew bundle' first."
    exit 1
fi

# Check if the config file exists
ITERM_CONFIG="$PROJECT_ROOT/configs/iterm2.itermexport"
if [ ! -f "$ITERM_CONFIG" ]; then
    echo "❌ Error: iTerm2 config file not found at $ITERM_CONFIG"
    exit 1
fi

# Apply the iTerm2 configuration
echo "Applying iTerm2 configuration from $ITERM_CONFIG..."

# Copy the configuration to iTerm2's preferences location
ITERM_PREFS_DIR="$HOME/Library/Application Support/iTerm2"
mkdir -p "$ITERM_PREFS_DIR"

# The .itermexport file can be imported by opening it or by copying to the right location
# We'll use the approach of setting up iTerm2 to load from our config directory
ITERM_DYNAMIC_PROFILES_DIR="$ITERM_PREFS_DIR/DynamicProfiles"
mkdir -p "$ITERM_DYNAMIC_PROFILES_DIR"

# Extract profiles from the .itermexport file if it contains JSON
if file "$ITERM_CONFIG" | grep -q "JSON"; then
    echo "Detected JSON format iTerm2 configuration"
    # For JSON format, we can extract profiles
    if command -v jq &> /dev/null; then
        # Extract profiles and copy to dynamic profiles
        jq '.Profiles[]?' "$ITERM_CONFIG" > "$ITERM_DYNAMIC_PROFILES_DIR/imported_profiles.json" 2>/dev/null || echo "Could not extract profiles with jq"
    fi
fi

# Set iTerm2 to load preferences from a custom directory
# This tells iTerm2 where to look for preferences
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$PROJECT_ROOT/configs"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo "✓ iTerm2 configuration applied successfully!"
