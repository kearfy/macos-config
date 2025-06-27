#!/bin/bash

echo "Setting up SurrealDB..."

# Check if SurrealDB is already installed
if command -v surreal &> /dev/null; then
    echo "SurrealDB is already installed"
    surreal version
else
    echo "Installing SurrealDB..."
    curl --proto '=https' --tlsv1.2 -sSf https://install.surrealdb.com | sh
    
    # Add to PATH if not already there
    if ! echo $PATH | grep -q "$HOME/.surrealdb"; then
        echo 'export PATH="$HOME/.surrealdb:$PATH"' >> ~/.zprofile
        export PATH="$HOME/.surrealdb:$PATH"
    fi
    
    echo "SurrealDB installation complete!"
    surreal version
fi
