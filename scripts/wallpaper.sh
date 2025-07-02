#!/bin/bash

# Handle interrupt signals (Ctrl+C) to exit cleanly
trap 'echo ""; echo "❌ Wallpaper setup interrupted by user. Exiting..."; exit 130' INT TERM

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if wallpaper name is provided
if [ -z "$1" ]; then
    echo "Usage: make wallpaper <name>"
    echo "Available wallpapers:"
    # Group wallpapers by basename and show extension only when there are conflicts
    if [ -d "$PROJECT_ROOT/wallpapers/" ]; then
        for file in "$PROJECT_ROOT/wallpapers/"*; do
            [ -f "$file" ] || continue
            filename=$(basename "$file")
            basename_only=$(echo "$filename" | sed 's/\.[^.]*$//')
            echo "$basename_only"
        done | sort | uniq -c | while read count name; do
            if [ "$count" -eq 1 ]; then
                echo "  - $name"
            else
                # Show all files with this basename
                ls -1 "$PROJECT_ROOT/wallpapers/" | grep "^$name\." | sed 's/^/  - /'
            fi
        done
    else
        echo "  No wallpapers directory found"
    fi
    exit 1
fi

WALLPAPER_NAME="$1"

# Function to find wallpaper file with or without extension
find_wallpaper() {
    local name="$1"
    local wallpapers_dir="$PROJECT_ROOT/wallpapers"
    
    # First, check if the exact filename exists
    if [ -f "$wallpapers_dir/$name" ]; then
        echo "$name"
        return 0
    fi
    
    # If not, look for files with this basename and common image extensions
    local matches=()
    for ext in jpg jpeg png heic gif bmp tiff; do
        if [ -f "$wallpapers_dir/$name.$ext" ]; then
            matches+=("$name.$ext")
        fi
    done
    
    # Return result based on number of matches
    case ${#matches[@]} in
        0)
            return 1 # No matches found
            ;;
        1)
            echo "${matches[0]}" # Single match, return it
            return 0
            ;;
        *)
            echo "MULTIPLE" # Multiple matches, require explicit extension
            return 2
            ;;
    esac
}

# Try to find the wallpaper file
FOUND_WALLPAPER=$(find_wallpaper "$WALLPAPER_NAME")
FIND_RESULT=$?

case $FIND_RESULT in
    1)
        echo "Error: Wallpaper file '$WALLPAPER_NAME' not found in wallpapers/ directory"
        echo "Available wallpapers:"
        ls -1 "$PROJECT_ROOT/wallpapers/" 2>/dev/null | sed 's/\.[^.]*$//' | sort -u | sed 's/^/  - /' || echo "No wallpapers directory found"
        exit 1
        ;;
    2)
        echo "Error: Multiple wallpapers found with name '$WALLPAPER_NAME'"
        echo "Please specify the full filename including extension:"
        ls -1 "$PROJECT_ROOT/wallpapers/" | grep "^$WALLPAPER_NAME\." | sed 's/^/  - /'
        exit 1
        ;;
    0)
        WALLPAPER_NAME="$FOUND_WALLPAPER"
        WALLPAPER_PATH="$PROJECT_ROOT/wallpapers/$WALLPAPER_NAME"
        ;;
esac

# Save the wallpaper selection
echo "$WALLPAPER_NAME" > "$PROJECT_ROOT/.wallpaper"
echo "Wallpaper set to: $WALLPAPER_NAME"

# Immediately apply the wallpaper
echo "Applying wallpaper..."
bash "$PROJECT_ROOT/components/wallpaper.sh"
