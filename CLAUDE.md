# Claude Code Memory - macOS Configuration Repository

This repository is a personal macOS configuration system that automates the setup of new Mac devices using shell scripts and Homebrew.

## Repository Structure

- **scripts/** - Main orchestration scripts
  - `adopt.sh` - One-liner installation script for new devices
  - `apply.sh` - Main configuration orchestrator
  - `init.sh` - Interactive setup wizard
  - `profile.sh` - Profile management (personal/work)
  - `status.sh` - Configuration status checker
  - `wallpaper.sh` - Wallpaper configuration

- **components/** - Modular configuration scripts for each tool/service
  - `brew.sh` - Package installation via Homebrew
  - `git.sh` - Git configuration with 1Password SSH integration
  - `rust.sh` - Rust toolchain setup
  - `bun.sh` - Bun JavaScript runtime
  - `surreal.sh` / `surrealist.sh` - SurrealDB setup
  - `vscode.sh` / `cursor.sh` - IDE configurations
  - `zsh.sh` - Shell configuration with Oh My Zsh
  - `macos.sh` - System settings and Dock configuration
  - `wallpaper.sh` - Desktop wallpaper setup
  - `personal.sh` - Personal profile specific setup

- **brew/** - Homebrew package definitions
  - `Brewfile` - Base packages for all profiles
  - `Brewfile.personal` - Personal profile specific packages
  - `Brewfile.work` - Work profile specific packages

- **configs/** - Application configuration files
  - `iterm2.itermexport` - iTerm2 settings

- **wallpapers/** - Available desktop backgrounds

## Key Commands

- `make init` - Run setup wizard
- `make apply` - Apply configuration (no sudo required)
- `make full` - Apply full configuration including system settings (requires sudo)
- `make profile <name>` - Set profile (personal/work)
- `make wallpaper <name>` - Set wallpaper
- `make status` - Show current configuration status

## Configuration Modes

- **Default Mode** (`make apply`) - User-level settings only, no sudo required
- **Full Mode** (`make full`) - Includes system-level settings requiring administrator privileges

## Profile System

The repository supports two profiles stored in `.profile`:
- **personal** - Includes gaming, personal messaging apps
- **work** - Focused on productivity and professional tools

## Development Environment

The configuration sets up a complete development environment with:
- Git with 1Password SSH agent integration
- Rust toolchain with WASM targets
- Node.js ecosystem (node, pnpm, yarn)
- Bun JavaScript runtime
- SurrealDB modern database
- VSCode and Cursor IDEs with extensions
- ZSH with Oh My Zsh and custom configuration

## Key Applications Installed

**Base (all profiles):**
- Development: VSCode, Cursor, Zed, iTerm2, Docker Desktop
- Productivity: 1Password, ChatGPT, Claude, Notion, Figma, Postman
- Utilities: BetterDisplay, AirBuddy, Arc browser, Google Chrome
- Communication: Discord

**Personal profile additions:**
- OpenJDK 21 (for Minecraft)
- WhatsApp, Telegram
- Various Mac App Store apps (Flighty, Home Assistant, Microsoft Office)

## System Customizations

The `macos.sh` component configures:
- Dock: Auto-hide, custom applications, no recent apps
- Finder: Show extensions, column view, status bar
- Screenshots: PNG format, custom location, no shadows
- Touch ID for sudo (in full mode)

## Best Practices

- All scripts are idempotent (safe to re-run)
- Graceful interrupt handling (Ctrl+C)
- Separation of user-level vs system-level settings
- Profile-based customization for different use cases
- Modular architecture for easy maintenance

## Testing Commands

When making changes, run:
- `make status` - Verify configuration state
- `make apply` - Test user-level changes
- `make full` - Test system-level changes (requires sudo)

All scripts can be run individually for testing: `bash components/vscode.sh`