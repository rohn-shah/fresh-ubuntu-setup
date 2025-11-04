#!/bin/bash

# dev-tools.sh - Install development tools (fzf, neovim, lazygit)
# This script installs essential command-line development tools

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Installing Development Tools${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# PHASE 1: INSTALL FZF (Fuzzy Finder)
# ============================================================================

echo -e "\n${YELLOW}Phase 1: Installing fzf (Fuzzy Finder)...${NC}"

FZF_DIR="$HOME/.fzf"

if [ -d "$FZF_DIR" ]; then
    echo -e "${GREEN}✓ fzf is already installed${NC}"
    echo -e "${YELLOW}Updating to latest version...${NC}"
    cd "$FZF_DIR"
    git pull
else
    echo -e "${YELLOW}Cloning fzf repository...${NC}"
    if git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"; then
        echo -e "${GREEN}✓ fzf repository cloned${NC}"
    else
        echo -e "${RED}✗ Failed to clone fzf repository${NC}"
        exit 1
    fi
fi

# Install fzf
echo -e "${YELLOW}Running fzf installation...${NC}"
if "$FZF_DIR/install" --all --no-bash --no-fish; then
    echo -e "${GREEN}✓ fzf installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install fzf${NC}"
    exit 1
fi

# ============================================================================
# PHASE 2: INSTALL NEOVIM
# ============================================================================

echo -e "\n${YELLOW}Phase 2: Installing Neovim...${NC}"

if command_exists nvim; then
    CURRENT_VERSION=$(nvim --version | head -n1)
    echo -e "${GREEN}✓ Neovim is already installed${NC}"
    echo -e "${BLUE}Current version: $CURRENT_VERSION${NC}"
    echo -e "${YELLOW}Checking for updates...${NC}"
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
if sudo apt install -y software-properties-common; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

# Add Neovim PPA for latest stable version
echo -e "${YELLOW}Adding Neovim stable PPA...${NC}"
if sudo add-apt-repository -y ppa:neovim-ppa/stable; then
    echo -e "${GREEN}✓ PPA added${NC}"
else
    echo -e "${RED}✗ Failed to add PPA${NC}"
    exit 1
fi

# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
if sudo apt update; then
    echo -e "${GREEN}✓ Package list updated${NC}"
else
    echo -e "${RED}✗ Failed to update package list${NC}"
    exit 1
fi

# Install/upgrade Neovim
echo -e "${YELLOW}Installing Neovim...${NC}"
if sudo apt install -y neovim; then
    echo -e "${GREEN}✓ Neovim installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install Neovim${NC}"
    exit 1
fi

# Verify installation
if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n1)
    echo -e "${GREEN}✓ Neovim is ready${NC}"
    echo -e "${BLUE}Version: $NVIM_VERSION${NC}"
else
    echo -e "${RED}✗ Neovim installation verification failed${NC}"
    exit 1
fi

# ============================================================================
# PHASE 2b: INSTALL LAZYVIM
# ============================================================================

echo -e "\n${YELLOW}Phase 2b: Installing LazyVim...${NC}"

NVIM_CONFIG="$HOME/.config/nvim"
NVIM_BACKUP="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"

# Check if nvim config already exists
if [ -d "$NVIM_CONFIG" ] && [ "$(ls -A $NVIM_CONFIG 2>/dev/null)" ]; then
    echo -e "${YELLOW}Existing Neovim config found${NC}"
    echo -e "${YELLOW}Backing up to: $NVIM_BACKUP${NC}"
    mv "$NVIM_CONFIG" "$NVIM_BACKUP"
    echo -e "${GREEN}✓ Backup created${NC}"
fi

# Backup other nvim data if exists
if [ -d "$HOME/.local/share/nvim" ]; then
    echo -e "${YELLOW}Backing up nvim data...${NC}"
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup.$(date +%Y%m%d_%H%M%S)"
fi

if [ -d "$HOME/.local/state/nvim" ]; then
    echo -e "${YELLOW}Backing up nvim state...${NC}"
    mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.backup.$(date +%Y%m%d_%H%M%S)"
fi

if [ -d "$HOME/.cache/nvim" ]; then
    echo -e "${YELLOW}Backing up nvim cache...${NC}"
    mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Clone LazyVim starter
echo -e "${YELLOW}Cloning LazyVim starter template...${NC}"
if git clone https://github.com/LazyVim/starter "$NVIM_CONFIG"; then
    echo -e "${GREEN}✓ LazyVim starter cloned${NC}"
else
    echo -e "${RED}✗ Failed to clone LazyVim starter${NC}"
    exit 1
fi

# Remove .git folder from starter (make it your own)
echo -e "${YELLOW}Removing .git folder from starter...${NC}"
rm -rf "$NVIM_CONFIG/.git"
echo -e "${GREEN}✓ LazyVim is ready for customization${NC}"

echo -e "\n${BLUE}LazyVim Setup Complete!${NC}"
echo -e "${YELLOW}On first launch, LazyVim will automatically install all plugins.${NC}"
echo -e "${YELLOW}This may take a few minutes.${NC}"

# ============================================================================
# PHASE 3: INSTALL LAZYGIT
# ============================================================================

echo -e "\n${YELLOW}Phase 3: Installing lazygit...${NC}"

if command_exists lazygit; then
    echo -e "${GREEN}✓ lazygit is already installed${NC}"
    echo -e "${BLUE}Current version: $(lazygit --version)${NC}"
    echo -e "${YELLOW}Checking for updates...${NC}"
fi

# Add lazygit PPA
echo -e "${YELLOW}Adding lazygit PPA...${NC}"
if sudo add-apt-repository -y ppa:lazygit-team/release; then
    echo -e "${GREEN}✓ PPA added${NC}"
else
    echo -e "${RED}✗ Failed to add PPA${NC}"
    exit 1
fi

# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
if sudo apt update; then
    echo -e "${GREEN}✓ Package list updated${NC}"
else
    echo -e "${RED}✗ Failed to update package list${NC}"
    exit 1
fi

# Install lazygit
echo -e "${YELLOW}Installing lazygit...${NC}"
if sudo apt install -y lazygit; then
    echo -e "${GREEN}✓ lazygit installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install lazygit${NC}"
    exit 1
fi

# Verify installation
if command_exists lazygit; then
    echo -e "${GREEN}✓ lazygit is ready${NC}"
    echo -e "${BLUE}Version: $(lazygit --version)${NC}"
else
    echo -e "${RED}✗ lazygit installation verification failed${NC}"
    exit 1
fi

# ============================================================================
# PHASE 4: CONFIGURE ZSH INTEGRATION
# ============================================================================

echo -e "\n${YELLOW}Phase 4: Configuring Zsh integration...${NC}"

ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
    # Add fzf to plugins if not already present
    if grep -q "^plugins=" "$ZSHRC"; then
        if grep "^plugins=" "$ZSHRC" | grep -q "fzf"; then
            echo -e "${GREEN}✓ fzf plugin already in .zshrc${NC}"
        else
            echo -e "${YELLOW}Adding fzf to Zsh plugins...${NC}"
            # Extract current plugins and add fzf
            CURRENT_PLUGINS=$(grep "^plugins=" "$ZSHRC" | sed 's/plugins=(//' | sed 's/)//')
            NEW_PLUGINS="plugins=($CURRENT_PLUGINS fzf)"
            sed -i "s|^plugins=.*|$NEW_PLUGINS|" "$ZSHRC"
            echo -e "${GREEN}✓ fzf plugin added to .zshrc${NC}"
        fi
    fi

    # Add lazygit alias if not present
    if ! grep -q "alias lg=" "$ZSHRC" 2>/dev/null; then
        echo -e "${YELLOW}Adding lazygit alias...${NC}"
        echo "" >> "$ZSHRC"
        echo "# Lazygit alias" >> "$ZSHRC"
        echo "alias lg='lazygit'" >> "$ZSHRC"
        echo -e "${GREEN}✓ Added 'lg' alias for lazygit${NC}"
    else
        echo -e "${GREEN}✓ lazygit alias already present${NC}"
    fi

    # Add nvim alias for vim if not present
    if ! grep -q "alias vim=" "$ZSHRC" 2>/dev/null; then
        echo -e "${YELLOW}Adding vim → nvim alias...${NC}"
        echo "" >> "$ZSHRC"
        echo "# Use Neovim instead of vim" >> "$ZSHRC"
        echo "alias vim='nvim'" >> "$ZSHRC"
        echo "alias vi='nvim'" >> "$ZSHRC"
        echo -e "${GREEN}✓ Added vim/vi → nvim aliases${NC}"
    else
        echo -e "${GREEN}✓ vim alias already present${NC}"
    fi
else
    echo -e "${YELLOW}⚠ .zshrc not found. Zsh integration skipped.${NC}"
    echo -e "${YELLOW}Run the zsh installation script first.${NC}"
fi

# ============================================================================
# PHASE 5: VERIFY NERD FONTS
# ============================================================================

echo -e "\n${YELLOW}Phase 5: Verifying Nerd Fonts...${NC}"

FONTS_DIR="$HOME/.local/share/fonts"

if ls "$FONTS_DIR"/MesloLGS*NF*.ttf >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Nerd Fonts detected (MesloLGS NF)${NC}"
    echo -e "${BLUE}Fonts installed:${NC}"
    ls -1 "$FONTS_DIR"/MesloLGS*NF*.ttf 2>/dev/null | xargs -n1 basename || true
    echo -e "${GREEN}✓ These fonts are compatible with Neovim icons and glyphs${NC}"
else
    echo -e "${YELLOW}⚠ Nerd Fonts not found in $FONTS_DIR${NC}"
    echo -e "${YELLOW}Neovim will work but may not display icons correctly${NC}"
    echo -e "${YELLOW}Run the zsh installation script to install MesloLGS NF fonts${NC}"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Development Tools Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}✓ fzf (Fuzzy Finder) installed${NC}"
echo -e "${GREEN}✓ Neovim installed${NC}"
echo -e "${GREEN}✓ LazyVim configured${NC}"
echo -e "${GREEN}✓ lazygit installed${NC}"

if [ -f "$ZSHRC" ]; then
    echo -e "${GREEN}✓ Zsh integration configured${NC}"
fi

echo -e "\n${BLUE}Quick Start Guide:${NC}"
echo -e ""
echo -e "${YELLOW}fzf (Fuzzy Finder):${NC}"
echo -e "  - Press ${CYAN}Ctrl+R${NC} - Search command history"
echo -e "  - Press ${CYAN}Ctrl+T${NC} - Search files in current directory"
echo -e "  - Press ${CYAN}Alt+C${NC}  - Change directory with fuzzy search"
echo -e "  - Use with any command: ${CYAN}vim \$(fzf)${NC}"
echo -e ""
echo -e "${YELLOW}Neovim + LazyVim:${NC}"
echo -e "  - Launch: ${CYAN}nvim${NC} or ${CYAN}vim${NC} (aliased)"
echo -e "  - First launch will auto-install all plugins (takes 2-3 minutes)"
echo -e "  - Config location: ${CYAN}~/.config/nvim/${NC}"
echo -e "  - LazyVim extras: Press ${CYAN}<leader>x${NC} (default leader is Space)"
echo -e "  - Plugin manager: Press ${CYAN}<leader>l${NC}"
echo -e "  - Nerd Fonts are installed for proper icon display"
echo -e ""
echo -e "${YELLOW}lazygit:${NC}"
echo -e "  - Launch: ${CYAN}lazygit${NC} or ${CYAN}lg${NC} (aliased)"
echo -e "  - Interactive Git UI for staging, committing, pushing, etc."
echo -e "  - Use inside any Git repository"
echo -e "  - Integrated with LazyVim (press ${CYAN}<leader>gg${NC} in nvim)"
echo -e ""
echo -e "${BLUE}Important: ${NC}"
echo -e "  - Restart your terminal or run ${CYAN}source ~/.zshrc${NC} to activate all changes"
echo -e "  - First ${CYAN}nvim${NC} launch will take 2-3 minutes to install plugins"
