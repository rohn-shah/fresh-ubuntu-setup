#!/bin/bash

# zsh.sh - Install and configure Zsh with Oh My Zsh and Powerlevel10k
# This script installs zsh, oh-my-zsh, powerlevel10k theme, plugins, and fonts

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Zsh with Oh My Zsh${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# PHASE 1: INSTALL ZSH
# ============================================================================

echo -e "\n${YELLOW}Phase 1: Installing Zsh...${NC}"

if command_exists zsh; then
    echo -e "${GREEN}✓ Zsh is already installed ($(zsh --version))${NC}"
else
    echo -e "${YELLOW}Installing Zsh...${NC}"
    if sudo apt install -y zsh; then
        echo -e "${GREEN}✓ Zsh installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Zsh${NC}"
        exit 1
    fi
fi

# ============================================================================
# PHASE 2: INSTALL OH MY ZSH
# ============================================================================

echo -e "\n${YELLOW}Phase 2: Installing Oh My Zsh...${NC}"

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}✓ Oh My Zsh is already installed${NC}"
else
    echo -e "${YELLOW}Downloading and installing Oh My Zsh...${NC}"

    # Download and run Oh My Zsh installer (unattended mode)
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        echo -e "${GREEN}✓ Oh My Zsh installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Oh My Zsh${NC}"
        exit 1
    fi
fi

# ============================================================================
# PHASE 3: INSTALL POWERLEVEL10K THEME
# ============================================================================

echo -e "\n${YELLOW}Phase 3: Installing Powerlevel10k Theme...${NC}"

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

if [ -d "$P10K_DIR" ]; then
    echo -e "${GREEN}✓ Powerlevel10k is already installed${NC}"
    echo -e "${YELLOW}Updating to latest version...${NC}"
    cd "$P10K_DIR"
    git pull
else
    echo -e "${YELLOW}Cloning Powerlevel10k repository...${NC}"
    if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"; then
        echo -e "${GREEN}✓ Powerlevel10k installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Powerlevel10k${NC}"
        exit 1
    fi
fi

# ============================================================================
# PHASE 4: INSTALL MESLO FONTS
# ============================================================================

echo -e "\n${YELLOW}Phase 4: Installing MesloLGS NF Fonts...${NC}"

FONTS_DIR="$HOME/.local/share/fonts"
SOURCE_FONTS="$PROJECT_ROOT/assets/fonts/MesloLGS"

if [ ! -d "$SOURCE_FONTS" ]; then
    echo -e "${RED}✗ Font directory not found: $SOURCE_FONTS${NC}"
    echo -e "${YELLOW}Skipping font installation...${NC}"
else
    # Create fonts directory
    mkdir -p "$FONTS_DIR"

    # Copy fonts
    echo -e "${YELLOW}Copying MesloLGS NF fonts...${NC}"
    cp "$SOURCE_FONTS"/*.ttf "$FONTS_DIR/"

    # Update font cache
    echo -e "${YELLOW}Updating font cache...${NC}"
    if command_exists fc-cache; then
        fc-cache -f -v > /dev/null 2>&1
        echo -e "${GREEN}✓ Fonts installed successfully${NC}"
        echo -e "${BLUE}Installed fonts:${NC}"
        ls -1 "$SOURCE_FONTS"/*.ttf | xargs -n1 basename
    else
        echo -e "${YELLOW}⚠ fc-cache not found, fonts copied but cache not updated${NC}"
    fi
fi

# ============================================================================
# PHASE 5: INSTALL ZSH PLUGINS
# ============================================================================

echo -e "\n${YELLOW}Phase 5: Installing Zsh Plugins...${NC}"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
echo -e "\n${YELLOW}Installing zsh-autosuggestions...${NC}"
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
    echo -e "${GREEN}✓ zsh-autosuggestions is already installed${NC}"
    echo -e "${YELLOW}Updating to latest version...${NC}"
    cd "$AUTOSUGGESTIONS_DIR"
    git pull
else
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"; then
        echo -e "${GREEN}✓ zsh-autosuggestions installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install zsh-autosuggestions${NC}"
        exit 1
    fi
fi

# Note: git, web-search, history, and jsontools are built-in Oh My Zsh plugins
echo -e "\n${BLUE}Built-in plugins (already available):${NC}"
echo -e "  - git"
echo -e "  - web-search"
echo -e "  - history"
echo -e "  - jsontools"

# ============================================================================
# PHASE 6: CONFIGURE .zshrc
# ============================================================================

echo -e "\n${YELLOW}Phase 6: Configuring .zshrc...${NC}"

ZSHRC="$HOME/.zshrc"

# Backup existing .zshrc
if [ -f "$ZSHRC" ]; then
    echo -e "${YELLOW}Backing up existing .zshrc to .zshrc.backup${NC}"
    cp "$ZSHRC" "$ZSHRC.backup"
fi

# Update theme
echo -e "${YELLOW}Setting Powerlevel10k as default theme...${NC}"
if grep -q "^ZSH_THEME=" "$ZSHRC" 2>/dev/null; then
    sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
    echo -e "${GREEN}✓ Theme updated in .zshrc${NC}"
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
    echo -e "${GREEN}✓ Theme added to .zshrc${NC}"
fi

# Update plugins
echo -e "${YELLOW}Configuring plugins...${NC}"
PLUGINS="plugins=(git zsh-autosuggestions web-search history jsontools)"

if grep -q "^plugins=" "$ZSHRC" 2>/dev/null; then
    sed -i "s|^plugins=.*|$PLUGINS|" "$ZSHRC"
    echo -e "${GREEN}✓ Plugins updated in .zshrc${NC}"
else
    echo "$PLUGINS" >> "$ZSHRC"
    echo -e "${GREEN}✓ Plugins added to .zshrc${NC}"
fi

# ============================================================================
# PHASE 7: SET ZSH AS DEFAULT SHELL
# ============================================================================

echo -e "\n${YELLOW}Phase 7: Setting Zsh as default shell...${NC}"

CURRENT_SHELL=$(echo $SHELL)

if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    echo -e "${GREEN}✓ Zsh is already the default shell${NC}"
else
    echo -e "${YELLOW}Changing default shell to Zsh...${NC}"
    echo -e "${YELLOW}You may be prompted for your password...${NC}\n"

    ZSH_PATH=$(which zsh)

    # Add zsh to /etc/shells if not present
    if ! grep -q "^$ZSH_PATH$" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    # Change default shell
    if chsh -s "$ZSH_PATH"; then
        echo -e "${GREEN}✓ Default shell changed to Zsh${NC}"
        echo -e "${YELLOW}Note: You'll need to log out and log back in for this to take effect${NC}"
    else
        echo -e "${RED}✗ Failed to change default shell${NC}"
        echo -e "${YELLOW}You can manually change it later with: chsh -s $(which zsh)${NC}"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Zsh Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}✓ Zsh installed${NC}"
echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
echo -e "${GREEN}✓ Powerlevel10k theme installed${NC}"
echo -e "${GREEN}✓ MesloLGS NF fonts installed${NC}"
echo -e "${GREEN}✓ Plugins configured: git, zsh-autosuggestions, web-search, history, jsontools${NC}"

echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "1. Log out and log back in (or open a new terminal)"
echo -e "2. The Powerlevel10k configuration wizard will run automatically"
echo -e "3. Follow the prompts to customize your prompt"
echo -e ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  - To reconfigure Powerlevel10k later: ${CYAN}p10k configure${NC}"
echo -e "  - To start using Zsh now without logging out: ${CYAN}zsh${NC}"
echo -e ""
echo -e "${BLUE}Your .zshrc has been configured with:${NC}"
echo -e "  - Theme: powerlevel10k/powerlevel10k"
echo -e "  - Plugins: git, zsh-autosuggestions, web-search, history, jsontools"
