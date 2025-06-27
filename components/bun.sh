#!/bin/bash

echo "Setting up Bun..."

# Check if Bun is already installed
if command -v bun &> /dev/null; then
    echo "Bun is already installed"
    bun --version
else
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    
    # Add to PATH if not already there
    if ! echo $PATH | grep -q "$HOME/.bun/bin"; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.zprofile
        export PATH="$HOME/.bun/bin:$PATH"
    fi
    
    echo "Bun installation complete!"
    bun --version
fi
