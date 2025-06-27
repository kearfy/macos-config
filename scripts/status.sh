#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "macOS Configuration Status"
echo "=========================="

if [ -f "$PROJECT_ROOT/.profile" ]; then
    PROFILE=$(cat "$PROJECT_ROOT/.profile")
    echo "Current profile: $PROFILE"
    echo "Available profiles: personal, work"
    echo ""
    echo "Profile-specific packages:"
    
    if [ "$PROFILE" = "work" ]; then
        echo "  - Linear (work productivity)"
        echo "  - Slack (team communication)"
    elif [ "$PROFILE" = "personal" ]; then
        echo "  - PolyMC (Minecraft launcher - installed via direct download)"
        echo "  - OpenJDK 21 (Java for Minecraft)"
        echo "  - WhatsApp Messenger"
        echo "  - Telegram"
    fi
else
    echo "❌ No profile set"
    echo "Available profiles: personal, work"
    echo "Use 'make profile <name>' to set a profile"
fi

echo ""

if [ -f "$PROJECT_ROOT/.wallpaper" ]; then
    WALLPAPER=$(cat "$PROJECT_ROOT/.wallpaper")
    # Show without extension if there's only one file with that basename
    BASENAME=$(echo "$WALLPAPER" | sed 's/\.[^.]*$//')
    MATCHES_COUNT=$(ls -1 "$PROJECT_ROOT/wallpapers/" 2>/dev/null | grep "^$BASENAME\." | wc -l)
    if [ "$MATCHES_COUNT" -eq 1 ]; then
        echo "Current wallpaper: $BASENAME"
    else
        echo "Current wallpaper: $WALLPAPER"
    fi
else
    echo "No wallpaper configured"
fi

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
