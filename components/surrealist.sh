#!/bin/bash

echo "Setting up Surrealist..."

# Function to get Surrealist version from Info.plist
get_installed_version() {
    if [ -f "/Applications/Surrealist.app/Contents/Info.plist" ]; then
        /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "/Applications/Surrealist.app/Contents/Info.plist" 2>/dev/null
    fi
}

# Function to install or update Surrealist
install_surrealist() {
    local action="$1"  # "Installing" or "Updating"
    
    echo "$action Surrealist..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Get the latest release info from GitHub API
    echo "Fetching latest Surrealist release information..."
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/surrealdb/surrealist/releases/latest")
    
    if [ $? -eq 0 ] && [ -n "$LATEST_RELEASE" ]; then
        # Extract the latest version
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
        
        # Extract the download URL for macOS dmg
        DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -o '"browser_download_url": "[^"]*\.dmg"' | head -n1 | cut -d'"' -f4)
        
        if [ -n "$DOWNLOAD_URL" ]; then
            echo "$action Surrealist $LATEST_VERSION from: $DOWNLOAD_URL"
            curl -L -o surrealist.dmg "$DOWNLOAD_URL"
            
            if [ $? -eq 0 ]; then
                # Mount the DMG
                echo "Mounting Surrealist DMG..."
                MOUNT_POINT=$(hdiutil attach surrealist.dmg -nobrowse -noautoopen | grep "/Volumes/" | awk '{print $3}')
                
                if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
                    # Find the .app file in the mounted volume
                    APP_FILE=$(find "$MOUNT_POINT" -name "*.app" -type d | head -n1)
                    
                    if [ -n "$APP_FILE" ]; then
                        # Remove old version if updating
                        if [ "$action" = "Updating" ] && [ -d "/Applications/Surrealist.app" ]; then
                            echo "Removing old Surrealist version..."
                            # Try to move to trash first, fall back to rm if needed
                            if command -v trash &> /dev/null; then
                                trash "/Applications/Surrealist.app" 2>/dev/null || rm -rf "/Applications/Surrealist.app" 2>/dev/null || true
                            else
                                rm -rf "/Applications/Surrealist.app" 2>/dev/null || true
                            fi
                            
                            # If removal failed, try a different approach
                            if [ -d "/Applications/Surrealist.app" ]; then
                                echo "Standard removal failed, trying alternative approach..."
                                # Create a backup name and install alongside
                                BACKUP_NAME="/Applications/Surrealist_old_$(date +%s).app"
                                mv "/Applications/Surrealist.app" "$BACKUP_NAME" 2>/dev/null || true
                                echo "Old version moved to: $BACKUP_NAME"
                                echo "You can manually delete it later if the update works correctly"
                            fi
                        fi
                        
                        # Copy to Applications folder
                        echo "Installing Surrealist to Applications..."
                        cp -R "$APP_FILE" /Applications/
                        
                        # Unmount the DMG
                        hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
                        
                        echo "Surrealist $action completed successfully!"
                        
                        return 0
                    else
                        echo "❌ Could not find app file in DMG"
                        hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
                        return 1
                    fi
                else
                    echo "❌ Failed to mount DMG"
                    return 1
                fi
            else
                echo "❌ Failed to download Surrealist"
                return 1
            fi
        else
            echo "❌ Could not find macOS DMG download URL in latest release"
            return 1
        fi
    else
        echo "❌ Failed to fetch latest release information"
        return 1
    fi
}

# Check if Surrealist is installed and handle installation/updates
if [ -d "/Applications/Surrealist.app" ]; then
    echo "Surrealist is installed. Checking for updates..."
    
    # Get installed version
    INSTALLED_VERSION=$(get_installed_version)
    
    if [ -n "$INSTALLED_VERSION" ]; then
        echo "Installed version: $INSTALLED_VERSION"
        
        # Get latest version from GitHub
        LATEST_RELEASE=$(curl -s "https://api.github.com/repos/surrealdb/surrealist/releases/latest")
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$LATEST_VERSION" ]; then
            echo "Latest version: $LATEST_VERSION"
            
            # Extract version number from tag (remove surrealist-v prefix if present)
            CLEAN_LATEST_VERSION=$(echo "$LATEST_VERSION" | sed 's/^surrealist-v//')
            
            if [ "$INSTALLED_VERSION" != "$CLEAN_LATEST_VERSION" ]; then
                echo "Update available! Updating Surrealist from $INSTALLED_VERSION to $CLEAN_LATEST_VERSION..."
                install_surrealist "Updating"
                UPDATE_RESULT=$?
            else
                echo "Surrealist is up to date!"
                UPDATE_RESULT=0
            fi
        else
            echo "Could not fetch latest version information"
            UPDATE_RESULT=0
        fi
    else
        echo "Could not determine installed version. Reinstalling..."
        install_surrealist "Reinstalling"
        UPDATE_RESULT=$?
    fi
else
    echo "Surrealist is not installed."
    install_surrealist "Installing"
    UPDATE_RESULT=$?
fi

# Fallback: provide manual download instructions if installation failed
if [ $UPDATE_RESULT -ne 0 ] || [ ! -d "/Applications/Surrealist.app" ]; then
    echo ""
    echo "Automatic installation failed. Please manually download Surrealist:"
    echo "1. Visit: https://github.com/surrealdb/surrealist/releases/latest"
    echo "2. Download the macOS DMG file"
    echo "3. Mount the DMG and drag Surrealist.app to your Applications folder"
fi

# Clean up
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
fi

echo "Surrealist setup complete!"
