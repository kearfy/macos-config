# macOS Configuration

This is my personal macOS configuration system that I use to set up new devices. It's built with shell scripts and Homebrew to provide a reproducible way to configure a macOS environment with my preferred applications, CLI tools, system settings, and development environments.

**Note:** This is tailored to my specific preferences and workflow. Feel free to fork this repository and customize it for your own needs!

## 🚀 Quick Install

```bash
bash <(curl -s https://raw.githubusercontent.com/kearfy/macos-config/main/scripts/adopt.sh)
```

This one-liner will clone the repository, run the setup wizard, and optionally apply your configuration.

## 📖 Commands

Once installed, use these commands from the project directory:

| Command | Description |
|---------|-------------|
| `make init` | Run the setup wizard to configure profile and wallpaper |
| `make apply` | Apply configuration (no sudo required) |
| `make full` | Apply full configuration including system settings (requires sudo) |
| `make profile <name>` | Set profile: `personal` or `work` |
| `make wallpaper <name>` | Set wallpaper from available options |
| `make status` | Show current configuration status |
| `make help` | Show all available commands |

## 📋 What Gets Installed

### Base Applications (All Profiles)
- **Development:** VSCode, Zed, iTerm2, Git, Node.js, Rust, Bun, Docker Desktop
- **Communication:** Discord  
- **Productivity:** 1Password, ChatGPT, Notion, Figma, Postman
- **Utilities:** BetterDisplay, AirBuddy, Google Chrome
- **Mac App Store:** 1Password for Safari, Microsoft Office, TestFlight

### Profile-Specific Applications
- **Personal:** PolyMC (Minecraft launcher)
- **Work:** Linear, Slack *(commented out by default)*

### Development Environment
- **Git:** User configuration with 1Password SSH agent
- **Rust:** Latest stable with WASM targets and rust-analyzer  
- **Bun:** JavaScript/TypeScript runtime and package manager
- **SurrealDB:** Modern database installation
- **ZSH:** Oh My Zsh with plugins and custom configuration
- **VSCode:** Development extensions and settings

### System Settings
- **Dock:** Auto-hide, profile-specific applications, no recent apps
- **Finder:** Show extensions, column view, status bar
- **Screenshots:** PNG format, custom location, no shadows
- **Window Manager:** Clean desktop, optimized settings

## 🛠️ Customization

This configuration reflects my personal preferences. To make it your own:

### Fork and Customize
1. Fork this repository
2. Update the adoption script URL to point to your fork
3. Modify applications, settings, and configurations to match your preferences

### Adding Applications
Edit the Brewfile to add applications:

```ruby
# Base applications (brew/Brewfile)
cask "my-new-app"
brew "my-cli-tool" 
mas "App Name", id: 123456789
```

### Modifying Settings
- **System preferences:** Edit `components/macos.sh`
- **VSCode extensions:** Modify `components/vscode.sh`
- **ZSH configuration:** Update `components/zsh.sh`

## 📁 Project Structure

```
├── scripts/
│   ├── adopt.sh         # New device setup script
│   ├── init.sh          # Interactive setup wizard
│   ├── apply.sh         # Main configuration script
│   └── profile.sh       # Profile management
├── brew/
│   ├── Brewfile         # Base packages
│   ├── Brewfile.personal # Personal-specific packages  
│   └── Brewfile.work    # Work-specific packages
├── components/          # Modular configuration scripts
│   ├── brew.sh          # Package installation
│   ├── git.sh           # Git and SSH setup
│   ├── rust.sh          # Rust toolchain
│   ├── macos.sh         # System settings
│   └── ...              # Other components
└── wallpapers/          # Available wallpaper options
```

## 🔧 Manual Setup Required

Some steps require manual configuration:

1. **App Store:** Sign in for Mac App Store installations
2. **1Password:** Install and enable SSH agent, Universal Autofill
3. **VSCode:** Sign in for settings sync
4. **Safari:** Set as default browser (if needed)

## 🔄 Re-running Configuration

All scripts are idempotent and safe to run multiple times:

```bash
make apply      # Re-apply everything
bash components/vscode.sh  # Re-run specific component
```
