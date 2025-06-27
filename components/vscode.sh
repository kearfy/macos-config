#!/bin/bash

echo "Configuring Visual Studio Code..."

# Check if VSCode app is installed
if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "VSCode is not installed. Please run 'brew bundle' first."
    exit 1
fi

# Setup code command if it doesn't exist
if ! command -v code &> /dev/null; then
    echo "Setting up 'code' command..."
    # Add VSCode bin to PATH temporarily for this session
    export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    
    # Create user-local bin directory and symlink (no sudo needed)
    mkdir -p "$HOME/.local/bin"
    if [ ! -L "$HOME/.local/bin/code" ]; then
        ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$HOME/.local/bin/code"
        echo "Created symlink at $HOME/.local/bin/code"
    fi
    
    # Add to PATH in shell profiles if not already there
    for profile in ~/.zshrc ~/.bash_profile ~/.bashrc; do
        if [ -f "$profile" ] && ! grep -q '$HOME/.local/bin' "$profile"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
        fi
    done
    
    # Define code function for this session as fallback
    code() {
        "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$@"
    }
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please run 'brew bundle' first."
    exit 1
fi

# VSCode settings directory and file
VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

# Create directory if it doesn't exist
mkdir -p "$VSCODE_SETTINGS_DIR"

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating new VSCode settings file..."
    echo '{}' > "$SETTINGS_FILE"
fi

# Update settings using jq
echo "Updating VSCode settings..."
jq '. + {
    "extensions.autoCheckUpdates": false,
    "update.mode": "none",
    "git.confirmSync": false,
    "git.autoFetch": true,
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.smoothScrolling": true,
    "terminal.integrated.smoothScrolling": true
}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

# Install extensions
echo "Installing VSCode extensions..."


# Function to install extension with retry logic
install_extension() {
    local ext_id="$1"
    local attempts=3
    local count=0
    
    while [ $count -lt $attempts ]; do
        echo "Installing extension: $ext_id (attempt $((count + 1))/$attempts)"
        if timeout 30 code --install-extension "$ext_id" --force 2>/dev/null; then
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

# Install extensions with better error handling

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

# GitHub and productivity
install_extension "github.copilot"
install_extension "github.copilot-chat"
install_extension "cardinal90.multi-cursor-case-preserve"
install_extension "million.million-lint"
install_extension "yoavbls.pretty-ts-errors"
install_extension "github.vscode-github-actions"
install_extension "usernamehw.errorlens"
install_extension "maattdd.gitless"

echo "VSCode configuration complete!"
echo "Settings applied and extensions installed."
