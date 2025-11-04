#!/bin/bash

# ghostty.sh - Install Ghostty Terminal
# This script installs Ghostty terminal emulator
# Note: Ghostty requires building from source on Linux

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Ghostty Terminal${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if Ghostty is already installed
ghostty_installed() {
    command -v ghostty >/dev/null 2>&1
}

if ghostty_installed; then
    echo -e "${GREEN}✓ Ghostty is already installed${NC}"
    echo -e "${YELLOW}Skipping installation...${NC}"
    exit 0
fi

echo -e "${YELLOW}Note: Ghostty requires building from source on Linux.${NC}"
echo -e "${YELLOW}This process will take several minutes.${NC}"
echo -e "${YELLOW}Required dependencies: zig, gtk4, libadwaita${NC}\n"

# Install build dependencies
echo -e "${YELLOW}Installing build dependencies...${NC}"
if sudo apt install -y git build-essential pkg-config libgtk-4-dev libadwaita-1-dev; then
    echo -e "${GREEN}✓ Build dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install build dependencies${NC}"
    exit 1
fi

# Install Zig (required for building Ghostty)
echo -e "\n${YELLOW}Checking for Zig compiler...${NC}"
if command -v zig >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Zig is already installed ($(zig version))${NC}"
else
    echo -e "${YELLOW}Installing Zig compiler...${NC}"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download latest Zig
    echo -e "${YELLOW}Downloading Zig...${NC}"
    if wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz; then
        echo -e "${GREEN}✓ Download complete${NC}"
    else
        echo -e "${RED}✗ Failed to download Zig${NC}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Extract and install
    tar -xf zig-linux-x86_64-0.13.0.tar.xz
    sudo mv zig-linux-x86_64-0.13.0 /opt/zig
    sudo ln -sf /opt/zig/zig /usr/local/bin/zig

    # Clean up
    cd ~
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN}✓ Zig installed successfully${NC}"
fi

# Clone Ghostty repository
echo -e "\n${YELLOW}Cloning Ghostty repository...${NC}"
INSTALL_DIR="$HOME/.local/src"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -d "ghostty" ]; then
    echo -e "${YELLOW}Repository already exists, pulling latest changes...${NC}"
    cd ghostty
    git pull
else
    if git clone https://github.com/ghostty-org/ghostty.git; then
        echo -e "${GREEN}✓ Repository cloned${NC}"
        cd ghostty
    else
        echo -e "${RED}✗ Failed to clone repository${NC}"
        exit 1
    fi
fi

# Build Ghostty
echo -e "\n${YELLOW}Building Ghostty (this may take a while)...${NC}"
if zig build -Doptimize=ReleaseFast; then
    echo -e "${GREEN}✓ Build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Install Ghostty
echo -e "\n${YELLOW}Installing Ghostty...${NC}"
if sudo zig build install -Doptimize=ReleaseFast --prefix /usr/local; then
    echo -e "${GREEN}✓ Installation successful${NC}"
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi

# Verify installation
if ghostty_installed; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Ghostty Installation Complete!${NC}"
    echo -e "${GREEN}You can launch it by running 'ghostty'${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi
