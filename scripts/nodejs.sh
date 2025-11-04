#!/bin/bash

# nodejs.sh - Install latest Node.js LTS
# This script installs the latest Node.js LTS version using NodeSource repository

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Node.js${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if Node.js is already installed
nodejs_installed() {
    command -v node >/dev/null 2>&1
}

if nodejs_installed; then
    CURRENT_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js is already installed (${CURRENT_VERSION})${NC}"
    echo -e "${YELLOW}This script will upgrade to the latest LTS version if needed.${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Skipping Node.js installation...${NC}"
        exit 0
    fi
fi

# Install dependencies
echo -e "\n${YELLOW}Installing dependencies...${NC}"
if sudo apt install -y curl; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

# Download and run NodeSource setup script for Node.js 22.x (Latest LTS)
echo -e "\n${YELLOW}Setting up NodeSource repository...${NC}"
if curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -; then
    echo -e "${GREEN}✓ NodeSource repository configured${NC}"
else
    echo -e "${RED}✗ Failed to setup NodeSource repository${NC}"
    exit 1
fi

# Install Node.js
echo -e "\n${YELLOW}Installing Node.js...${NC}"
if sudo apt install -y nodejs; then
    echo -e "${GREEN}✓ Node.js installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install Node.js${NC}"
    exit 1
fi

# Verify installation
if nodejs_installed; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Node.js Installation Complete!${NC}"
    echo -e "${GREEN}Node.js Version: ${NODE_VERSION}${NC}"
    echo -e "${GREEN}npm Version: ${NPM_VERSION}${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi
