#!/bin/bash

echo "Configuring Rust..."

# Source the Rust environment if it exists
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Check if Rust is installed
if ! command -v rustc &> /dev/null; then
    echo "Rust is not installed. Please run 'brew bundle' first."
    exit 1
fi

# Add WASM targets
echo "Adding WASM targets..."
rustup target add wasm32-unknown-unknown
rustup target add wasm32-wasip1

# Add rust-analyzer component
echo "Adding rust-analyzer..."
rustup component add rust-analyzer

# Optionally add other useful components
echo "Adding additional Rust components..."
rustup component add rustfmt
rustup component add clippy

echo "Rust configuration complete!"
echo "Available targets:"
rustup target list --installed
echo ""
echo "Available components:"
rustup component list --installed
