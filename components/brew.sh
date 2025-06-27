#!/bin/bash

echo "Setting up Homebrew..."

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed"
fi

# Install mas (Mac App Store command line interface) if not present
if ! command -v mas &> /dev/null; then
    echo "Installing mas..."
    brew install mas
fi

# Apply Brewfile (change to parent directory where Brewfile is located)
echo "Installing packages from Brewfile..."
cd "$(dirname "$0")/../brew"
brew bundle --file="Brewfile"

# Apply profile-specific Brewfile if it exists
if [ -n "$MACOS_CONFIG_PROFILE" ] && [ -f "Brewfile.$MACOS_CONFIG_PROFILE" ]; then
    echo "Installing profile-specific packages from Brewfile.$MACOS_CONFIG_PROFILE..."
    brew bundle --file="Brewfile.$MACOS_CONFIG_PROFILE"
else
    echo "No profile-specific Brewfile found or profile not set"
fi

echo "Homebrew setup complete!"
