#!/bin/bash

# gnome-tools.sh - Install GNOME Tweaks and Extensions
# This script installs GNOME Tweaks and extensions support

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing GNOME Tools${NC}"
echo -e "${YELLOW}========================================${NC}"

# Check if running GNOME
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ]; then
    echo -e "${YELLOW}Warning: You don't appear to be running GNOME desktop${NC}"
    echo -e "${YELLOW}Current desktop: ${XDG_CURRENT_DESKTOP}${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Skipping GNOME tools installation...${NC}"
        exit 0
    fi
fi

# Update package list
echo -e "\n${YELLOW}Updating package list...${NC}"
if sudo apt update; then
    echo -e "${GREEN}✓ Package list updated${NC}"
else
    echo -e "${RED}✗ Failed to update package list${NC}"
    exit 1
fi

# Install GNOME Tweaks
echo -e "\n${YELLOW}Installing GNOME Tweaks...${NC}"
if command -v gnome-tweaks >/dev/null 2>&1; then
    echo -e "${GREEN}✓ GNOME Tweaks is already installed${NC}"
else
    if sudo apt install -y gnome-tweaks; then
        echo -e "${GREEN}✓ GNOME Tweaks installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install GNOME Tweaks${NC}"
        exit 1
    fi
fi

# Install GNOME Shell Extensions
echo -e "\n${YELLOW}Installing GNOME Shell Extensions...${NC}"
if sudo apt install -y gnome-shell-extensions; then
    echo -e "${GREEN}✓ GNOME Shell Extensions installed${NC}"
else
    echo -e "${RED}✗ Failed to install GNOME Shell Extensions${NC}"
    exit 1
fi

# Install Extension Manager (formerly GNOME Extensions app)
echo -e "\n${YELLOW}Installing Extension Manager...${NC}"
if command -v extension-manager >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Extension Manager is already installed${NC}"
else
    if sudo apt install -y gnome-shell-extension-manager 2>/dev/null || sudo apt install -y extension-manager 2>/dev/null; then
        echo -e "${GREEN}✓ Extension Manager installed${NC}"
    else
        echo -e "${YELLOW}⚠ Extension Manager not available in repositories${NC}"
        echo -e "${YELLOW}You can install it manually via Flatpak or from extensions.gnome.org${NC}"
    fi
fi

# Install Chrome GNOME Shell integration (for browser extension support)
echo -e "\n${YELLOW}Installing Chrome GNOME Shell integration...${NC}"
if sudo apt install -y chrome-gnome-shell; then
    echo -e "${GREEN}✓ Chrome GNOME Shell integration installed${NC}"
    echo -e "${YELLOW}Note: Install browser extension from https://extensions.gnome.org${NC}"
else
    echo -e "${YELLOW}⚠ Failed to install Chrome GNOME Shell integration${NC}"
fi

# Install some useful default extensions
echo -e "\n${YELLOW}Installing additional useful extensions...${NC}"
if sudo apt install -y gnome-shell-extension-appindicator gnome-shell-extension-gsconnect 2>/dev/null; then
    echo -e "${GREEN}✓ Additional extensions installed${NC}"
else
    echo -e "${YELLOW}⚠ Some extensions may not be available${NC}"
fi

# ============================================================================
# Install specific GNOME extensions from extensions.gnome.org
# ============================================================================

echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Custom GNOME Extensions${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to install a GNOME extension
install_extension() {
    local extension_id="$1"
    local extension_name="$2"

    echo -e "\n${YELLOW}Installing $extension_name (ID: $extension_id)...${NC}"

    # Detect GNOME Shell version
    GNOME_VERSION=$(gnome-shell --version 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    if [ -z "$GNOME_VERSION" ]; then
        echo -e "${RED}✗ Could not detect GNOME Shell version${NC}"
        return 1
    fi

    # Extract major version (e.g., "45" from "45.2")
    SHELL_VERSION=$(echo "$GNOME_VERSION" | cut -d. -f1)

    echo -e "${BLUE}Detected GNOME Shell version: $GNOME_VERSION (using $SHELL_VERSION)${NC}"

    # Query extension info from extensions.gnome.org API
    API_URL="https://extensions.gnome.org/extension-info/?pk=${extension_id}&shell_version=${SHELL_VERSION}"

    # Create temp directory
    TEMP_DIR=$(mktemp -d)

    # Download extension info
    if ! curl -sS "$API_URL" -o "$TEMP_DIR/info.json"; then
        echo -e "${RED}✗ Failed to query extension info${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Check if extension is compatible
    if grep -q "does not support" "$TEMP_DIR/info.json" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Extension not compatible with GNOME Shell $SHELL_VERSION${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Extract download URL and UUID
    DOWNLOAD_URL=$(grep -Po '"download_url":\s*"\K[^"]*' "$TEMP_DIR/info.json" 2>/dev/null)
    UUID=$(grep -Po '"uuid":\s*"\K[^"]*' "$TEMP_DIR/info.json" 2>/dev/null)

    if [ -z "$DOWNLOAD_URL" ] || [ -z "$UUID" ]; then
        echo -e "${RED}✗ Could not extract extension details${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Check if extension is already installed
    if [ -d "/usr/share/gnome-shell/extensions/$UUID" ] || [ -d "$HOME/.local/share/gnome-shell/extensions/$UUID" ]; then
        echo -e "${GREEN}✓ $extension_name is already installed${NC}"
        rm -rf "$TEMP_DIR"
        return 0
    fi

    # Download extension
    echo -e "${BLUE}Downloading from: https://extensions.gnome.org${DOWNLOAD_URL}${NC}"
    if ! curl -sS "https://extensions.gnome.org${DOWNLOAD_URL}" -o "$TEMP_DIR/extension.zip"; then
        echo -e "${RED}✗ Failed to download extension${NC}"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Install system-wide
    echo -e "${YELLOW}Installing to /usr/share/gnome-shell/extensions/$UUID${NC}"
    sudo mkdir -p "/usr/share/gnome-shell/extensions/$UUID"

    if ! sudo unzip -q "$TEMP_DIR/extension.zip" -d "/usr/share/gnome-shell/extensions/$UUID"; then
        echo -e "${RED}✗ Failed to extract extension${NC}"
        sudo rm -rf "/usr/share/gnome-shell/extensions/$UUID"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Set proper permissions
    sudo chmod -R 755 "/usr/share/gnome-shell/extensions/$UUID"

    # Clean up
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN}✓ $extension_name installed successfully${NC}"
    echo -e "${BLUE}UUID: $UUID${NC}"

    return 0
}

# Install required packages for extension installation
if ! command -v unzip >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Installing unzip (required for extension installation)...${NC}"
    sudo apt install -y unzip
fi

# Install extensions
install_extension "3193" "Blur my Shell"
install_extension "307" "Dash to Dock"
install_extension "19" "User Themes"
install_extension "6807" "System Monitor"
install_extension "1414" "Unblank Lock Screen"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}GNOME Tools Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Important: You MUST log out and log back in for extensions to work${NC}"
echo -e "${YELLOW}After logging back in:${NC}"
echo -e "${YELLOW}  1. Open 'Extensions' app or GNOME Tweaks to enable installed extensions${NC}"
echo -e "${YELLOW}  2. Use 'gnome-tweaks' to customize your desktop${NC}"
echo -e "${YELLOW}  3. Configure User Themes extension to use custom shell themes${NC}"
