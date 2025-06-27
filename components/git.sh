#!/bin/bash

echo "Configuring Git..."

# Check if Git is installed (should be available on macOS by default)
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing via Homebrew..."
    brew install git
fi

# Configure Git user information
echo "Setting Git user configuration..."
git config --global user.name "Micha de Vries"
git config --global user.email "micha@devrie.sh"

# Configure Git behavior
echo "Setting Git behavior configuration..."
git config --global pull.rebase true
git config --global init.defaultBranch main

# Configure Git signing with 1Password
echo "Setting up Git signing with 1Password..."
git config --global user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbopZzjJo93/8gCABVMZLwjO0OeqyusYiB+tbPIS5Gx"
git config --global gpg.format ssh
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
git config --global commit.gpgsign true

# Configure SSH for 1Password integration
echo "Setting up SSH for 1Password integration..."

# Create SSH config directory if it doesn't exist
mkdir -p "$HOME/.ssh"

# Create or update SSH config for 1Password
SSH_CONFIG="$HOME/.ssh/config"

# Backup existing SSH config if it exists
if [ -f "$SSH_CONFIG" ]; then
    cp "$SSH_CONFIG" "$SSH_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Check if 1Password SSH agent config already exists
if ! grep -q "IdentityAgent" "$SSH_CONFIG" 2>/dev/null; then
    echo "Adding 1Password SSH agent configuration..."
    cat >> "$SSH_CONFIG" << 'EOF'

# 1Password SSH Agent
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

EOF
else
    echo "1Password SSH agent configuration already exists in SSH config"
fi

# Set proper permissions for SSH config
chmod 600 "$SSH_CONFIG"

echo "Git configuration complete!"
echo "Current Git configuration:"
echo "User: $(git config --global user.name) <$(git config --global user.email)>"
echo "Signing key: $(git config --global user.signingkey)"
echo "GPG format: $(git config --global gpg.format)"
echo ""
echo "Make sure 1Password is installed and SSH agent is enabled in 1Password settings."
