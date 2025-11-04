#!/bin/bash

# vscode.sh - Install Visual Studio Code
# This script installs the latest VSCode from Microsoft's repository

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Visual Studio Code${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if VSCode is already installed
vscode_installed() {
    command -v code >/dev/null 2>&1
}

if vscode_installed; then
    echo -e "${GREEN}✓ VSCode is already installed ($(code --version | head -n1))${NC}"
    echo -e "${YELLOW}Skipping installation...${NC}"
    exit 0
fi

# Install dependencies
echo -e "\n${YELLOW}Installing dependencies...${NC}"
if sudo apt install -y wget gpg apt-transport-https; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

# Download and install Microsoft GPG key
echo -e "\n${YELLOW}Adding Microsoft GPG key...${NC}"
if wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; then
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    rm -f packages.microsoft.gpg
    echo -e "${GREEN}✓ GPG key added${NC}"
else
    echo -e "${RED}✗ Failed to add GPG key${NC}"
    exit 1
fi

# Add VSCode repository
echo -e "\n${YELLOW}Adding VSCode repository...${NC}"
if echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null; then
    echo -e "${GREEN}✓ Repository added${NC}"
else
    echo -e "${RED}✗ Failed to add repository${NC}"
    exit 1
fi

# Update package list
echo -e "\n${YELLOW}Updating package list...${NC}"
if sudo apt update; then
    echo -e "${GREEN}✓ Package list updated${NC}"
else
    echo -e "${RED}✗ Failed to update package list${NC}"
    exit 1
fi

# Install VSCode
echo -e "\n${YELLOW}Installing VSCode...${NC}"
if sudo apt install -y code; then
    echo -e "${GREEN}✓ VSCode installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install VSCode${NC}"
    exit 1
fi

# Verify installation
if vscode_installed; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}VSCode Installation Complete!${NC}"
    echo -e "${GREEN}Version: $(code --version | head -n1)${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi
