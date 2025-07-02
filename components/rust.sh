#!/bin/bash

echo "Configuring Rust..."

# Check if Rust is already installed
if command -v rustc &> /dev/null && command -v cargo &> /dev/null && command -v rustup &> /dev/null; then
    echo "Rust is already installed"
    echo "Current version: $(rustc --version)"
else
    echo "Installing Rust using the official installer..."
    # Install Rust using the official script
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    
    # Source the cargo environment
    source "$HOME/.cargo/env"
    
    echo "Rust installed successfully"
    echo "Installed version: $(rustc --version)"
fi

# Ensure cargo bin directory is in PATH for this session
export PATH="$HOME/.cargo/bin:$PATH"

# Verify installation
echo "Verifying Rust installation..."
if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null || ! command -v rustup &> /dev/null; then
    echo "❌ Rust installation verification failed"
    exit 1
fi

echo "✅ Rust installation verified"
echo "  rustc: $(which rustc)"
echo "  cargo: $(which cargo)" 
echo "  rustup: $(which rustup)"
echo "  version: $(rustc --version)"

# Ensure we have the stable toolchain as default
echo "Ensuring stable toolchain is default..."
rustup default stable

# Add useful components
echo "Installing Rust components..."
rustup component add rustfmt clippy rust-analyzer

# Add WASM targets
echo "Adding WASM targets..."
rustup target add wasm32-unknown-unknown wasm32-wasip1

echo "🦀 Rust configuration complete!"
