#!/bin/bash

echo "Configuring ZSH..."

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed"
fi

# Install additional plugins that need to be cloned
echo "Installing additional Oh My Zsh plugins..."

# Install autojump via brew if not already installed
if ! command -v autojump &> /dev/null; then
    echo "Installing autojump..."
    brew install autojump
fi

# Install thefuck via brew if not already installed
if ! command -v thefuck &> /dev/null; then
    echo "Installing thefuck..."
    brew install thefuck
fi

# Install direnv via brew if not already installed
if ! command -v direnv &> /dev/null; then
    echo "Installing direnv..."
    brew install direnv
fi

# Create/update .zshrc
echo "Configuring .zshrc..."

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

cat > "$HOME/.zshrc" << 'EOF'
# Disable compfix to avoid the insecure directories warning
ZSH_DISABLE_COMPFIX=true

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(
    git
    1password
    man
    autojump
    deno
    node
    npm
    rust
    ssh
    thefuck
    vscode
    direnv
)

source $ZSH/oh-my-zsh.sh

# Shell aliases
alias ll="ls -l"
alias lg="lazygit"
alias sr="surreal sql --conn memory --user root --pass root --ns test --db test --pretty"

# Environment variables
# Dynamically find the latest LLVM version installed by Homebrew
if [ -d "/opt/homebrew/Cellar/llvm" ]; then
    LLVM_VERSION=$(ls /opt/homebrew/Cellar/llvm/ | sort -V | tail -n 1)
    export CC=/opt/homebrew/Cellar/llvm/$LLVM_VERSION/bin/clang
    export AR=/opt/homebrew/Cellar/llvm/$LLVM_VERSION/bin/llvm-ar
fi
export PATH=/opt/homebrew/opt/llvm/bin:/Users/micha/.cargo/bin:$PATH

# Additional PATH exports (from other components)
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.surrealdb:$PATH"

# Autojump
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Direnv hook
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Thefuck
if command -v thefuck > /dev/null; then
    eval $(thefuck --alias)
fi
EOF

echo "ZSH configuration complete!"
echo "The .zshrc file has been created/updated."
echo "Please restart your terminal or open a new terminal session for changes to take effect."
