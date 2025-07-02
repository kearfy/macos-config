#!/bin/bash

echo "Configuring Rust..."

# Source the Rust environment if it exists
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Check if rustup-init is available and run initial setup
if command -v rustup-init &> /dev/null && ! command -v rustup &> /dev/null; then
    echo "Running rustup-init to set up Rust toolchain..."
    rustup-init -y --no-modify-path
    source "$HOME/.cargo/env"
    echo "Rust toolchain initialized"
elif ! command -v rustup &> /dev/null; then
    echo "Neither rustup nor rustup-init found. Installing rustup..."
    # Fallback: Install rustup directly
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
    echo "rustup installed successfully"
fi

# Check if Rust is now available
if ! command -v rustc &> /dev/null; then
    echo "❌ Rust installation failed. Please install Rust manually."
    exit 1
fi

echo "Using Rust version: $(rustc --version)"

# Ensure rustup has a default toolchain configured
# Check if rustup can run without errors, if not, set up default toolchain
echo "Checking rustup configuration..."
if ! rustup default &> /dev/null; then
    echo "Setting up default Rust toolchain..."
    rustup default stable
    echo "Default toolchain set to stable"
else
    echo "Rustup default toolchain already configured"
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
