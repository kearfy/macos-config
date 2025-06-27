#!/bin/bash

echo "Configuring desktop wallpaper..."

# Check if wallpaper selection file exists
WALLPAPER_FILE=".wallpaper"
if [ ! -f "$WALLPAPER_FILE" ]; then
    echo "No wallpaper configured. Use 'make wallpaper <name>' to set a wallpaper."
    exit 0
fi

# Read the selected wallpaper name
WALLPAPER_NAME=$(cat "$WALLPAPER_FILE")
echo "Setting wallpaper: $WALLPAPER_NAME"

# Define wallpaper path
WALLPAPER_PATH="wallpapers/$WALLPAPER_NAME"

# Check if the wallpaper file exists
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Wallpaper file not found at $WALLPAPER_PATH"
    echo "Available wallpapers:"
    ls -1 wallpapers/ 2>/dev/null || echo "No wallpapers directory found"
    exit 1
fi

# Get absolute path for wallpaper
WALLPAPER_ABSOLUTE_PATH="$(pwd)/$WALLPAPER_PATH"

# Set the wallpaper using AppleScript
echo "Applying wallpaper: $WALLPAPER_ABSOLUTE_PATH"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_ABSOLUTE_PATH\""

if [ $? -eq 0 ]; then
    echo "Wallpaper successfully applied!"
else
    echo "Error: Failed to apply wallpaper"
    exit 1
fi
