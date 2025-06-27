#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if profile argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <profile>"
    echo "Available profiles: personal, work"
    exit 1
fi

PROFILE="$1"

# Validate profile
if [ "$PROFILE" != "personal" ] && [ "$PROFILE" != "work" ]; then
    echo "❌ Invalid profile: $PROFILE"
    echo "Available profiles: personal, work"
    exit 1
fi

# Set the profile
echo "$PROFILE" > "$PROJECT_ROOT/.profile"
echo "Profile set to: $PROFILE"
