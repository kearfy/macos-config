#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🎯 Welcome to macOS Configuration Setup!"
echo ""
echo "This script will help you configure your macOS environment."
echo ""

# Check if already configured
if [ -f "$PROJECT_ROOT/.profile" ]; then
    current_profile=$(cat "$PROJECT_ROOT/.profile")
    echo "📋 Current configuration:"
    echo "   Profile: $current_profile"
    echo ""
    read -p "Do you want to reconfigure? (y/N): " reconfigure
    if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
        echo "Configuration unchanged."
        exit 0
    fi
    echo ""
fi

# Profile selection
echo "📝 Step 1: Choose your profile"
echo ""
echo "Available profiles:"
echo "  1) personal - Personal development setup"
echo "  2) work     - Work environment setup"
echo ""

while true; do
    read -p "Select profile (1 or 2): " profile_choice
    case $profile_choice in
        1)
            PROFILE="personal"
            break
            ;;
        2)
            PROFILE="work"
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac
done

echo "✅ Profile set to: $PROFILE"
echo ""

# Wallpaper selection
echo "🖼️  Step 2: Choose your wallpaper"
echo ""
echo "Available wallpapers:"

# List available wallpapers
wallpaper_options=()
if [ -d "$PROJECT_ROOT/wallpapers/" ]; then
    i=1
    for file in "$PROJECT_ROOT/wallpapers/"*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            basename_only=$(echo "$filename" | sed 's/\.[^.]*$//')
            echo "  $i) $basename_only"
            wallpaper_options[$i]="$basename_only"
            ((i++))
        fi
    done
else
    echo "  No wallpapers directory found"
fi

if [ ${#wallpaper_options[@]} -eq 0 ]; then
    echo "❌ No wallpapers available. Skipping wallpaper setup."
    WALLPAPER=""
else
    echo "  0) Skip wallpaper setup"
    echo ""
    
    while true; do
        read -p "Select wallpaper (0-${#wallpaper_options[@]}): " wallpaper_choice
        if [ "$wallpaper_choice" = "0" ]; then
            WALLPAPER=""
            echo "⏭️  Wallpaper setup skipped"
            break
        elif [ "$wallpaper_choice" -ge 1 ] && [ "$wallpaper_choice" -le ${#wallpaper_options[@]} ] 2>/dev/null; then
            WALLPAPER="${wallpaper_options[$wallpaper_choice]}"
            echo "✅ Wallpaper set to: $WALLPAPER"
            break
        else
            echo "Invalid choice. Please enter a number between 0 and ${#wallpaper_options[@]}."
        fi
    done
fi

echo ""

# Apply configuration
echo "💾 Saving configuration..."

# Set profile
echo "$PROFILE" > "$PROJECT_ROOT/.profile"
echo "✅ Profile saved: $PROFILE"

# Set wallpaper if selected
if [ -n "$WALLPAPER" ]; then
    echo "$WALLPAPER" > "$PROJECT_ROOT/.wallpaper"
    echo "✅ Wallpaper preference saved: $WALLPAPER"
fi

echo ""
echo "🎉 Initial configuration complete!"
echo ""
echo "Next steps:"
echo "  • Run 'make apply' to apply the configuration (without system-level changes)"
echo "  • Run 'make full' to apply the full configuration (includes system-level changes, requires sudo)"
echo "  • Run 'make status' to check the current configuration status"
echo ""
