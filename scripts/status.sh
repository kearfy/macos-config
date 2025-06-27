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
