#!/bin/bash

echo "Configuring Cursor..."

# Check if Cursor app is installed
if [ ! -d "/Applications/Cursor.app" ]; then
    echo "Cursor is not installed. Please run 'brew bundle' first."
    echo "Or download from: https://cursor.sh"
    exit 1
fi

# Setup cursor command if it doesn't exist
if ! command -v cursor &> /dev/null; then
    echo "Setting up 'cursor' command..."
    # Add Cursor bin to PATH temporarily for this session
    export PATH="/Applications/Cursor.app/Contents/Resources/app/bin:$PATH"
    
    # Create user-local bin directory and symlink (no sudo needed)
    mkdir -p "$HOME/.local/bin"
    if [ ! -L "$HOME/.local/bin/cursor" ]; then
        ln -sf "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" "$HOME/.local/bin/cursor"
        echo "Created symlink at $HOME/.local/bin/cursor"
    fi
    
    # Add to PATH in shell profiles if not already there
    for profile in ~/.zshrc ~/.bash_profile ~/.bashrc; do
        if [ -f "$profile" ] && ! grep -q '$HOME/.local/bin' "$profile"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
        fi
    done
    
    # Define cursor function for this session as fallback
    cursor() {
        "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" "$@"
    }
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please run 'brew bundle' first."
    exit 1
fi

# Cursor settings directory and file
CURSOR_SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
SETTINGS_FILE="$CURSOR_SETTINGS_DIR/settings.json"

# Create directory if it doesn't exist
mkdir -p "$CURSOR_SETTINGS_DIR"

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating new Cursor settings file..."
    echo '{}' > "$SETTINGS_FILE"
fi

# Update settings using jq
echo "Updating Cursor settings..."
jq '. + {
    "extensions.autoCheckUpdates": false,
    "update.mode": "none",
    "git.confirmSync": false,
    "git.autoFetch": true,
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.smoothScrolling": true,
    "terminal.integrated.smoothScrolling": true,
    "cursor.cpp.disabledLanguages": [],
    "cursor.chat.alwaysSearchWeb": false
}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

# Install extensions
echo "Installing Cursor extensions..."

# Get list of installed extensions once to avoid SIGPIPE errors
echo "Checking currently installed extensions..."
INSTALLED_EXTENSIONS=$(cursor --list-extensions 2>/dev/null || echo "")

# Function to install extension with retry logic
install_extension() {
    local ext_id="$1"
    
    # Check if extension is already installed using cached list
    if echo "$INSTALLED_EXTENSIONS" | grep -q "^${ext_id}$"; then
        echo "✓ Extension $ext_id is already installed"
        return 0
    fi
    
    local attempts=3
    local count=0
    
    while [ $count -lt $attempts ]; do
        echo "Installing extension: $ext_id (attempt $((count + 1))/$attempts)"
        if timeout 30 cursor --install-extension "$ext_id" --force 2>/dev/null; then
            echo "✓ Successfully installed $ext_id"
            return 0
        else
            echo "⚠ Failed to install $ext_id (attempt $((count + 1)))"
            count=$((count + 1))
            if [ $count -lt $attempts ]; then
                echo "Retrying in 2 seconds..."
                sleep 2
            fi
        fi
    done
    
    echo "✗ Failed to install $ext_id after $attempts attempts"
    return 1
}

# Install extensions with better error handling (excluding Copilot/ChatGPT)

# Nix
install_extension "bbenoist.nix"
install_extension "jnoortheen.nix-ide"
install_extension "mkhl.direnv"

# Language support
install_extension "surrealdb.surrealql"
install_extension "ms-vscode.makefile-tools"
install_extension "rust-lang.rust-analyzer"
install_extension "dustypomerleau.rust-syntax"
install_extension "astro-build.astro-vscode"
install_extension "biomejs.biome"
install_extension "unifiedjs.vscode-mdx"
install_extension "ms-vscode.vscode-typescript-next"
install_extension "mrmlnc.vscode-scss"
install_extension "bradlc.vscode-tailwindcss"
install_extension "oven.bun-vscode"
install_extension "tauri-apps.tauri-vscode"
install_extension "tamuratak.vscode-lezer"
install_extension "ms-python.python"
install_extension "ms-python.vscode-pylance"
install_extension "ms-python.debugpy"

# Productivity (excluding Copilot extensions)
install_extension "cardinal90.multi-cursor-case-preserve"
install_extension "million.million-lint"
install_extension "yoavbls.pretty-ts-errors"
install_extension "github.vscode-github-actions"
install_extension "usernamehw.errorlens"
install_extension "maattdd.gitless"

echo "Cursor configuration complete!"
echo "Settings applied and extensions installed."
echo "Note: GitHub Copilot and ChatGPT extensions were excluded as requested."
