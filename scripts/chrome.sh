#!/bin/bash

# chrome.sh - Install Google Chrome browser
# This script downloads and installs the latest Google Chrome

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Google Chrome${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if Chrome is already installed
chrome_installed() {
    command -v google-chrome >/dev/null 2>&1
}

if chrome_installed; then
    echo -e "${GREEN}✓ Google Chrome is already installed ($(google-chrome --version))${NC}"
    echo -e "${YELLOW}Skipping installation...${NC}"
    exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo -e "\n${YELLOW}Downloading Google Chrome...${NC}"
if wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
    echo -e "${GREEN}✓ Download complete${NC}"
else
    echo -e "${RED}✗ Failed to download Google Chrome${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "\n${YELLOW}Installing Google Chrome...${NC}"
if sudo dpkg -i google-chrome-stable_current_amd64.deb; then
    echo -e "${GREEN}✓ Google Chrome installed successfully${NC}"
else
    echo -e "${YELLOW}Fixing dependencies...${NC}"
    if sudo apt install -f -y; then
        echo -e "${GREEN}✓ Dependencies fixed and Google Chrome installed${NC}"
    else
        echo -e "${RED}✗ Failed to install Google Chrome${NC}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

# Clean up
cd ~
rm -rf "$TEMP_DIR"

# Verify installation
if chrome_installed; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Google Chrome Installation Complete!${NC}"
    echo -e "${GREEN}Version: $(google-chrome --version)${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi
