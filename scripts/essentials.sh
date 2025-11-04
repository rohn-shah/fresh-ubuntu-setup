#!/bin/bash

# essentials.sh - Install curl, wget, and git
# This script installs essential command-line tools

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Essential Tools${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list
echo -e "\n${YELLOW}Updating package list...${NC}"
if sudo apt update; then
    echo -e "${GREEN}✓ Package list updated successfully${NC}"
else
    echo -e "${RED}✗ Failed to update package list${NC}"
    exit 1
fi

# Install curl
echo -e "\n${YELLOW}Installing curl...${NC}"
if command_exists curl; then
    echo -e "${GREEN}✓ curl is already installed ($(curl --version | head -n1))${NC}"
else
    if sudo apt install -y curl; then
        echo -e "${GREEN}✓ curl installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install curl${NC}"
        exit 1
    fi
fi

# Install wget
echo -e "\n${YELLOW}Installing wget...${NC}"
if command_exists wget; then
    echo -e "${GREEN}✓ wget is already installed ($(wget --version | head -n1))${NC}"
else
    if sudo apt install -y wget; then
        echo -e "${GREEN}✓ wget installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install wget${NC}"
        exit 1
    fi
fi

# Install git
echo -e "\n${YELLOW}Installing git...${NC}"
if command_exists git; then
    echo -e "${GREEN}✓ git is already installed ($(git --version))${NC}"
else
    if sudo apt install -y git; then
        echo -e "${GREEN}✓ git installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install git${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Essential Tools Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
