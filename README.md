# macOS Configuration

A reproducible macOS configuration system inspired by Nix Darwin, using shell scripts and Homebrew. This setup provides a declarative way to configure your macOS environment with applications, CLI tools, system settings, and development environments.

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd macos-config
   ```

2. **Set your profile:**
   ```bash
   # For personal use
   make profile personal
   
   # For work use
   make profile work
   ```

3. **Run the configuration:**
   ```bash
   # Default mode (no sudo commands)
   make apply
   
   # Full mode (includes system-level settings)
   make full
   ```

## Profile System

This configuration supports profile-based customization to install different applications and configure the dock based on your use case:

### Available Profiles

**Personal Profile (`make profile personal`):**
- Installs base applications plus personal-specific tools
- Downloads and installs PolyMC (Minecraft launcher) directly from GitHub releases
- Installs OpenJDK 21 (required for latest Minecraft versions) via Homebrew
- Configures Java PATH for optimal Minecraft compatibility
- Adds PolyMC to the dock
- Suitable for personal development and gaming

**Work Profile (`make profile work`):**
- Installs base applications plus work-specific tools  
- Adds Linear (project management) and Slack (team communication)
- Adds Linear and Slack to the dock
- Suitable for professional development and team collaboration

### Profile Management

```bash
# Set a profile (required before first run)
make profile personal  # or 'make profile work'

# Check current profile and status
make status

# Switch profiles anytime
make profile work      # Switch to work profile
make apply            # Re-run to apply new profile settings
```

**Note:** The profile setting is stored in `.profile` (gitignored) and must be set before running any configuration commands. Profile validation is handled by the shell scripts, keeping the Makefile simple and focused.

## Configuration Modes

### Default Mode (`make apply`)
- Installs Homebrew and applications via Brewfile
- Configures Git, Rust, Bun, SurrealDB, ZSH, and VSCode
- Sets user-level preferences (Dock, Finder, Screenshots, etc.)
- **No sudo commands** - safe to run without password prompts

### Full Mode (`make full`)
- Everything from default mode
- **Plus:** System-level settings requiring sudo:
  - Login window settings (guest account, login text, user display)
  - NVRAM settings (boot chime)
  - Touch ID for sudo
- **Note:** LaunchServices database rebuild is disabled to prevent System Settings issues

## What Gets Installed & Configured

### Applications (via Brewfile)

**Base Applications (all profiles):**
- **Development:** VSCode, Zed, iTerm2, Git, Node.js, Rust, Bun, SurrealDB
- **Communication:** Discord, Telegram, WhatsApp
- **Productivity:** 1Password, ChatGPT, Notion, Figma, Postman
- **Utilities:** BetterDisplay, AirBuddy, and many CLI tools
- **Mac App Store:** 1Password for Safari

**Profile-Specific Applications:**
- **Work Profile:** Linear (project management), Slack (team communication)
- **Personal Profile:** PolyMC (Minecraft launcher)

### Development Environment
- **Git:** User configuration, 1Password SSH agent integration
- **Rust:** Latest stable with WASM targets and rust-analyzer
- **Bun:** JavaScript/TypeScript runtime and package manager
- **SurrealDB:** Modern database for web applications
- **ZSH:** Oh My Zsh with plugins and custom configuration
- **VSCode:** Extensions and settings for development

### System Settings
- **Dock:** Auto-hide, custom applications, no recent apps
- **Finder:** Show extensions, column view, status bar
- **Screenshots:** PNG format, custom location, no shadows
- **Window Manager:** Hide desktop icons, global stage manager

## Component Structure

The configuration is modular, with each component handling a specific area:

```
components/
├── brew.sh      # Homebrew installation and Brewfile application
├── git.sh       # Git configuration and 1Password SSH setup
├── rust.sh      # Rust toolchain and components
├── bun.sh       # Bun JavaScript runtime
├── surreal.sh   # SurrealDB installation
├── zsh.sh       # ZSH and Oh My Zsh configuration
├── vscode.sh    # VSCode settings and extensions
└── macos.sh     # macOS system settings and Dock setup
```

## Customization

### Adding Applications
Edit the appropriate Brewfile in the `brew/` directory to add new applications:
```ruby
# Base applications (brew/Brewfile)
cask "my-new-app"
brew "my-cli-tool"
mas "App Name", id: 123456789

# Work-specific applications (brew/Brewfile.work)
cask "work-specific-app"

# Personal-specific applications (brew/Brewfile.personal)
cask "personal-app"
```

### Modifying System Settings
Edit `components/macos.sh` to add or modify system preferences:
```bash
# Example: Change dock size
defaults write com.apple.dock tilesize -int 50
```

### VSCode Configuration
- **Extensions:** Modify the extensions list in `components/vscode.sh`
- **Settings:** Edit the JSON settings object in the same file

### ZSH Configuration
- **Plugins:** Modify the plugins array in `components/zsh.sh`
- **Aliases:** Add custom aliases to the aliases section
- **Environment:** Add environment variables as needed

## Manual Steps Required

Some setup steps cannot be automated and require manual intervention:

### Before Running
1. **App Store Login:** Sign in to the Mac App Store for `mas` to work
2. **1Password:** Install and sign in to enable SSH agent integration

### After Running
1. **1Password Universal Autofill:** 
   - Open System Settings → Privacy & Security → Accessibility
   - Click the '+' button and add 1Password
   - Enable the toggle for 1Password
   - In 1Password app: Settings → Autofill → Universal Autofill → Enable

2. **Safari AutoFill (if needed):**
   - If Safari still shows autofill options, manually disable them in Safari → Settings → AutoFill

3. **Default Browser (if automatic setting fails):**
   - If Safari isn't set as the default browser automatically, go to System Settings → Desktop & Dock → Default web browser → Safari

4. **VSCode:** Sign in to GitHub/Microsoft accounts for settings sync

5. **System Restart:** Some system settings may require a restart to take full effect

### Optional Manual Configurations

**LaunchServices Database Rebuild:**
If you experience application recognition issues, you can manually rebuild the LaunchServices database:
```bash
sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
```
⚠️ **Warning:** This may cause System Settings to become unresponsive, requiring a restart.

## Troubleshooting

### Common Issues

**"rustup: command not found" errors:**
- The Rust script now automatically sources the Rust environment
- If issues persist, restart your terminal or run `source ~/.cargo/env`

**Safari preferences errors:**
- Safari settings may require manual configuration due to app sandboxing
- To disable autofill manually: Safari → Settings → AutoFill → uncheck all options

**VSCode extension installation crashes:**
- Close VSCode completely before running the configuration
- The script now includes retry logic and better error handling
- If issues persist, run `bash components/vscode.sh` separately

**System Settings app becomes unresponsive:**
- **FIXED:** The issue was caused by LaunchServices database rebuild (`lsregister`)
- This command has been disabled to prevent System Settings from breaking
- If you need to rebuild LaunchServices manually, be aware it may require a restart
- The configuration should now be stable in both default and full modes

**"Command not found" errors:**
- Run `source ~/.zshrc` or restart your terminal
- Ensure Homebrew is properly installed and in PATH

**Dock applications not appearing:**
- Some applications may need to be launched once before appearing in Dock
- Run `/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user`

**1Password SSH not working:**
- Ensure 1Password is installed and SSH agent is enabled
- Check that `~/.ssh/config` includes the 1Password agent configuration

### Re-running Configuration
All scripts are designed to be idempotent - safe to run multiple times:
```bash
# Re-run specific components
bash components/vscode.sh
bash components/zsh.sh

# Or re-run everything
make apply
```

## File Structure

```
├── scripts/
│   ├── apply.sh         # Main orchestration script
│   ├── profile.sh       # Profile management script
│   └── status.sh        # Status display script
├── brew/
│   ├── Brewfile         # Base Homebrew package definitions  
│   ├── Brewfile.personal # Personal profile specific packages
│   └── Brewfile.work    # Work profile specific packages
├── .profile             # Current profile setting (gitignored)
├── Makefile             # Build targets (apply, full, profile)
├── README.md            # This documentation
└── components/          # Modular configuration scripts
    ├── brew.sh          # Homebrew and package installation
    ├── bun.sh           # Bun runtime setup
    ├── git.sh           # Git and SSH configuration
    ├── macos.sh         # System settings and Dock
    ├── rust.sh          # Rust toolchain setup
    ├── surreal.sh       # SurrealDB installation
    ├── vscode.sh        # VSCode configuration
    └── zsh.sh           # Shell and terminal setup
```

## Dependencies

The following tools are automatically installed if missing:
- **Homebrew:** Package manager for macOS
- **jq:** JSON processor for VSCode settings
- **dockutil:** Dock management utility
- **mas:** Mac App Store command line interface

## Environment Variables

- `MACOS_CONFIG_FULL`: When set to `1`, enables system-level settings requiring sudo
- `MACOS_CONFIG_PROFILE`: Current profile setting (personal/work), automatically exported from `.profile`
- `HOMEBREW_NO_INSTALL_CLEANUP`: Reduces Homebrew noise during installation
- `HOMEBREW_NO_ENV_HINTS`: Suppresses Homebrew environment hints

**Important:** The `MACOS_CONFIG_FULL` variable is automatically managed by the Makefile and **does not persist** in your shell after the scripts complete. It only affects the current script execution and its child processes.

## Security Considerations

- Default mode requires no password/sudo access
- Full mode uses Touch ID for sudo when available
- SSH keys are managed through 1Password for enhanced security
- All downloaded scripts are from official sources

## Inspiration

This configuration system is inspired by:
- **Nix Darwin:** Declarative macOS configuration
- **Homebrew Bundle:** Package management via Brewfile
- **dotfiles:** Community best practices for dotfile management

## Contributing

1. Test changes in both default and full modes
2. Ensure scripts remain idempotent
3. Update this README for any new features or requirements
4. Consider backward compatibility when modifying existing components

## License

[Add your preferred license here]
