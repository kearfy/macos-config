#!/bin/bash

echo "Configuring macOS system settings..."

# Check if full configuration mode is enabled
if [ "${MACOS_CONFIG_FULL}" = "1" ]; then
    echo "Full configuration mode enabled - applying system-level settings..."
    
    # Enable sudo with Touch ID
    echo "Enabling sudo with Touch ID..."
    if ! grep -q "pam_tid.so" /etc/pam.d/sudo 2>/dev/null; then
        echo "auth       sufficient     pam_tid.so" | sudo tee -a /etc/pam.d/sudo > /dev/null
        echo "Touch ID for sudo enabled"
    else
        echo "Touch ID for sudo already enabled"
    fi
else
    echo "Default mode - skipping system-level settings requiring sudo"
    echo "Use 'make full' to enable all system settings"
fi

# Dock Settings
echo "Configuring Dock settings..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.0
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock expose-animation-duration -float 0.4
defaults write com.apple.dock launchanim -bool true
defaults write com.apple.dock mineffect -string "genie"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock static-only -bool false
defaults write com.apple.dock tilesize -int 35
defaults write com.apple.dock magnification -bool true

# Set dock applications using dockutil
echo "Setting Dock applications..."

# Clear existing dock first
dockutil --remove all --no-restart

# Function to add dock item based on profile
add_dock_item() {
    local profile_filter="$1"
    local app_path="$2"
    local app_name="$3"
    
    # Check if this item should be added for the current profile
    if [ "$profile_filter" = "all" ] || [ "$profile_filter" = "$MACOS_CONFIG_PROFILE" ]; then
        if [ -d "$app_path" ] || [ -e "$app_path" ]; then
            dockutil --add "$app_path" --no-restart
            echo "Added $app_name to dock (profile: $profile_filter)"
        else
            echo "Skipping $app_name - not found at $app_path"
        fi
    fi
}

# Define dock items in order with profile filters
echo "Configuring dock for profile: $MACOS_CONFIG_PROFILE"

add_dock_item "all" "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app" "Safari"
add_dock_item "all" "/Applications/Cursor.app" "Cursor"
add_dock_item "all" "/Applications/Visual Studio Code.app" "Visual Studio Code"
add_dock_item "all" "/Applications/Zed.app" "Zed"
add_dock_item "all" "/Applications/iTerm.app" "iTerm2"
add_dock_item "all" "/Applications/Surrealist.app" "Surrealist"
add_dock_item "all" "/Applications/1Password.app" "1Password"
add_dock_item "all" "/System/Applications/Music.app" "Apple Music"
add_dock_item "all" "/System/Applications/Calendar.app" "Calendar"
add_dock_item "work" "/Applications/Linear.app" "Linear"
add_dock_item "all" "/Applications/ChatGPT.app" "ChatGPT"
add_dock_item "all" "/Applications/Discord.app" "Discord"
add_dock_item "all" "/System/Applications/Mail.app" "Mail"
add_dock_item "personal" "/System/Applications/Messages.app" "Messages"
add_dock_item "work" "/Applications/Slack.app" "Slack"
add_dock_item "personal" "/Applications/WhatsApp.app" "WhatsApp"
add_dock_item "personal" "/Applications/Telegram.app" "Telegram"
add_dock_item "personal" "/Applications/PolyMC.app" "PolyMC"
add_dock_item "personal" "/System/Applications/App Store.app" "App Store"
add_dock_item "personal" "/System/Applications/Home.app" "Home"
add_dock_item "all" "/System/Applications/System Settings.app" "System Settings"

# Finder Settings
echo "Configuring Finder settings..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool false
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder QuitMenuItem -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool false

# Login Window Settings (requires sudo)
if [ "${MACOS_CONFIG_FULL}" = "1" ]; then
    echo "Configuring Login Window settings..."
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false 2>/dev/null || true
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "micha@devrie.sh" 2>/dev/null || true
    sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool false 2>/dev/null || true
    sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "" 2>/dev/null || true
else
    echo "Skipping Login Window settings (requires sudo - use 'make full')"
fi

# Screenshot Settings
echo "Configuring Screenshot settings..."
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture location -string "~/Pictures/screenshots"
defaults write com.apple.screencapture show-thumbnail -bool true
defaults write com.apple.screencapture type -string "png"

# Create screenshots directory if it doesn't exist
mkdir -p ~/Pictures/screenshots

# Text Input and Keyboard Settings
echo "Configuring text input and keyboard settings..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable macOS Passwords app and autofill (using 1Password instead)
echo "Disabling macOS Passwords app and autofill..."
defaults write com.apple.Safari AutoFillPasswords -bool false 2>/dev/null || true
defaults write com.apple.Safari AutoFillCreditCardData -bool false 2>/dev/null || true
defaults write com.apple.Safari AutoFillFromAddressBook -bool false 2>/dev/null || true
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false 2>/dev/null || true
defaults write NSGlobalDomain com.apple.AutoFillPasswords -bool false 2>/dev/null || true

# Default Browser Settings
echo "Setting Safari as default browser..."
# Check if defaultbrowser utility is available (installed via Homebrew)
if command -v defaultbrowser &> /dev/null; then
    defaultbrowser safari
    echo "Safari set as default browser using defaultbrowser utility"
else
    echo "❌ Error: defaultbrowser utility not found"
    echo "Please install it with: brew install defaultbrowser"
    echo "Or manually set Safari as default browser in System Settings → Desktop & Dock → Default web browser"
fi

# Window Manager Settings
echo "Configuring Window Manager settings..."
defaults write com.apple.WindowManager HideDesktop -bool true 2>/dev/null || true
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true 2>/dev/null || true

# Music App Settings
echo "Configuring Music app settings..."
defaults write com.apple.Music userWantsPlaybackNotifications -bool false

# System Startup Settings (requires sudo)
if [ "${MACOS_CONFIG_FULL}" = "1" ]; then
    echo "Configuring system startup settings..."
    sudo nvram StartupMute=%01 2>/dev/null || true
else
    echo "Skipping system startup settings (requires sudo - use 'make full')"
fi

echo "Restarting affected services..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "macOS system configuration complete!"