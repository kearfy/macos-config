#!/bin/bash

echo "Setting up personal profile applications..."

# Function to get PolyMC version from Info.plist
get_installed_version() {
    if [ -f "/Applications/PolyMC.app/Contents/Info.plist" ]; then
        /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "/Applications/PolyMC.app/Contents/Info.plist" 2>/dev/null
    fi
}

# Function to install or update PolyMC
install_polymc() {
    local action="$1"  # "Installing" or "Updating"
    
    echo "$action PolyMC..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get the latest release info from GitHub API
    echo "Fetching latest PolyMC release information..."
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/PolyMC/PolyMC/releases/latest")
    
    if [ $? -eq 0 ] && [ -n "$LATEST_RELEASE" ]; then
        # Extract the latest version
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
        
        # Extract the download URL for macOS (prefer non-legacy version)
        DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -o '"browser_download_url": "[^"]*macOS[^"]*\.tar\.gz"' | grep -v "Legacy" | head -n1 | cut -d'"' -f4)
        
        if [ -n "$DOWNLOAD_URL" ]; then
            echo "$action PolyMC $LATEST_VERSION from: $DOWNLOAD_URL"
            curl -L -o polymc.tar.gz "$DOWNLOAD_URL"
            
            if [ $? -eq 0 ]; then
                # Extract the archive
                echo "Extracting PolyMC..."
                tar -xzf polymc.tar.gz
                
                # Remove old version if updating
                if [ "$action" = "Updating" ] && [ -d "/Applications/PolyMC.app" ]; then
                    echo "Removing old PolyMC version..."
                    # Try to move to trash first, fall back to rm if needed
                    if command -v trash &> /dev/null; then
                        trash "/Applications/PolyMC.app" 2>/dev/null || rm -rf "/Applications/PolyMC.app" 2>/dev/null || true
                    else
                        rm -rf "/Applications/PolyMC.app" 2>/dev/null || true
                    fi
                    
                    # If removal failed, try a different approach
                    if [ -d "/Applications/PolyMC.app" ]; then
                        echo "Standard removal failed, trying alternative approach..."
                        # Create a backup name and install alongside
                        BACKUP_NAME="/Applications/PolyMC_old_$(date +%s).app"
                        mv "/Applications/PolyMC.app" "$BACKUP_NAME" 2>/dev/null || true
                        echo "Old version moved to: $BACKUP_NAME"
                        echo "You can manually delete it later if the update works correctly"
                    fi
                fi
                
                # Move to Applications folder (using cp instead of mv to avoid sudo)
                echo "Installing PolyMC to Applications..."
                if [ -d "PolyMC.app" ]; then
                    cp -R PolyMC.app /Applications/
                    echo "PolyMC $action completed successfully!"
                    return 0
                else
                    echo "❌ PolyMC.app not found in archive"
                    return 1
                fi
            else
                echo "❌ Failed to download PolyMC"
                return 1
            fi
        else
            echo "❌ Could not find macOS download URL in latest release"
            return 1
        fi
    else
        echo "❌ Failed to fetch latest release information"
        return 1
    fi
}

# Check if PolyMC is installed and handle installation/updates
if [ -d "/Applications/PolyMC.app" ]; then
    echo "PolyMC is installed. Checking for updates..."
    
    # Get installed version
    INSTALLED_VERSION=$(get_installed_version)
    
    if [ -n "$INSTALLED_VERSION" ]; then
        echo "Installed version: $INSTALLED_VERSION"
        
        # Get latest version from GitHub
        LATEST_RELEASE=$(curl -s "https://api.github.com/repos/PolyMC/PolyMC/releases/latest")
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$LATEST_VERSION" ]; then
            echo "Latest version: $LATEST_VERSION"
            
            if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
                echo "Update available! Updating PolyMC..."
                install_polymc "Updating"
                UPDATE_RESULT=$?
            else
                echo "PolyMC is up to date!"
                UPDATE_RESULT=0
            fi
        else
            echo "Could not fetch latest version information"
            UPDATE_RESULT=0
        fi
    else
        echo "Could not determine installed version. Reinstalling..."
        install_polymc "Reinstalling"
        UPDATE_RESULT=$?
    fi
else
    echo "PolyMC is not installed."
    install_polymc "Installing"
    UPDATE_RESULT=$?
fi

# Fallback: provide manual download instructions if installation failed
if [ $UPDATE_RESULT -ne 0 ] || [ ! -d "/Applications/PolyMC.app" ]; then
    echo ""
    echo "Automatic installation failed. Please manually download PolyMC:"
    echo "1. Visit: https://polymc.org/download/"
    echo "2. Download the macOS version"
    echo "3. Drag PolyMC.app to your Applications folder"
fi

# Clean up
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
fi

echo "Personal profile setup complete!"

# Configure Java for Minecraft
echo "Configuring Java for Minecraft..."

# Check if OpenJDK 21 is installed
if command -v java &> /dev/null; then
    JAVA_VERSION_OUTPUT=$(java -version 2>&1 | head -n1)
    echo "Java version output: $JAVA_VERSION_OUTPUT"
    
    # Extract major version number (works for both old and new Java version formats)
    JAVA_VERSION=$(echo "$JAVA_VERSION_OUTPUT" | sed -n 's/.*"\([0-9]*\)\..*/\1/p' 2>/dev/null)
    if [ -z "$JAVA_VERSION" ]; then
        # Try alternative extraction for newer Java versions
        JAVA_VERSION=$(echo "$JAVA_VERSION_OUTPUT" | sed -n 's/.*"\([0-9]*\)".*/\1/p' 2>/dev/null)
    fi
    
    if [ -n "$JAVA_VERSION" ] && [ "$JAVA_VERSION" -ge 21 ] 2>/dev/null; then
        echo "Java $JAVA_VERSION is available for Minecraft"
    else
        echo "Java version is older than 21 or could not be determined. OpenJDK 21 should be available via Homebrew."
    fi
else
    echo "Java not found in PATH. OpenJDK 21 should be installed via Brewfile."
fi

# Add Java to PATH if needed (for OpenJDK installed via Homebrew)
JAVA_HOME_21="/opt/homebrew/opt/openjdk@21"
if [ -d "$JAVA_HOME_21" ]; then
    # Check if Java 21 is working
    if "$JAVA_HOME_21/bin/java" -version &> /dev/null; then
        HOMEBREW_JAVA_VERSION=$("$JAVA_HOME_21/bin/java" -version 2>&1 | head -n1 | sed -n 's/.*"\([0-9]*\)".*/\1/p')
        echo "Homebrew OpenJDK $HOMEBREW_JAVA_VERSION is installed and working"
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$JAVA_HOME_21/bin:"* ]]; then
            echo "Adding OpenJDK 21 to PATH..."
            if ! grep -q "openjdk@21" ~/.zshrc 2>/dev/null; then
                echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
                echo "OpenJDK 21 added to PATH. Restart your terminal or run 'source ~/.zshrc' to use it."
            else
                echo "OpenJDK 21 PATH already configured in ~/.zshrc"
            fi
        else
            echo "OpenJDK 21 is already in PATH"
        fi
        
        # Configure PolyMC to use the correct Java path
        echo "Configuring PolyMC to use OpenJDK 21..."
        POLYMC_CONFIG_DIR="$HOME/Library/Application Support/PolyMC"
        
        if [ -d "/Applications/PolyMC.app" ]; then
            # Create PolyMC config directory if it doesn't exist
            mkdir -p "$POLYMC_CONFIG_DIR"
            
            # Create or update the Java configuration
            JAVA_CONFIG_FILE="$POLYMC_CONFIG_DIR/multimc.cfg"
            
            # Check if config file exists and has Java path
            if [ -f "$JAVA_CONFIG_FILE" ]; then
                # Update existing config
                if grep -q "JavaPath=" "$JAVA_CONFIG_FILE"; then
                    # Replace existing JavaPath
                    sed -i.backup "s|JavaPath=.*|JavaPath=$JAVA_HOME_21/bin/java|" "$JAVA_CONFIG_FILE"
                    echo "Updated Java path in existing PolyMC configuration"
                else
                    # Add JavaPath to existing config
                    echo "JavaPath=$JAVA_HOME_21/bin/java" >> "$JAVA_CONFIG_FILE"
                    echo "Added Java path to existing PolyMC configuration"
                fi
            else
                # Create new config file with Java path
                cat > "$JAVA_CONFIG_FILE" << EOF
# PolyMC Configuration
JavaPath=$JAVA_HOME_21/bin/java
EOF
                echo "Created new PolyMC configuration with Java path"
            fi
            
            echo "PolyMC should now detect Java 21 automatically"
            echo "If PolyMC is open, please restart it to load the new configuration"
        else
            echo "PolyMC not found - configuration will be applied when PolyMC is installed"
        fi
    fi
else
    echo "OpenJDK 21 not found in expected Homebrew location. Make sure 'brew install openjdk@21' completed successfully."
fi

echo "Personal profile setup complete!"
