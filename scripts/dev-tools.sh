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

# Install Neovim using AppImage (more reliable than PPA)
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

echo -e "${YELLOW}Downloading Neovim AppImage...${NC}"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"

if curl -fLo "$BIN_DIR/nvim.appimage" "$NVIM_URL"; then
    echo -e "${GREEN}✓ Neovim AppImage downloaded${NC}"
else
    echo -e "${RED}✗ Failed to download Neovim${NC}"
    exit 1
fi

# Make it executable
chmod +x "$BIN_DIR/nvim.appimage"

# Create symlink
ln -sf "$BIN_DIR/nvim.appimage" "$BIN_DIR/nvim"

echo -e "${GREEN}✓ Neovim installed successfully${NC}"

# Verify installation
if "$BIN_DIR/nvim" --version >/dev/null 2>&1; then
    NVIM_VERSION=$("$BIN_DIR/nvim" --version 2>/dev/null | head -n1)
    echo -e "${GREEN}✓ Neovim is ready${NC}"
    echo -e "${BLUE}Version: $NVIM_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Note: You may need to restart your terminal or run 'source ~/.zshrc'${NC}"
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

# Get latest lazygit version and install from GitHub releases
echo -e "${YELLOW}Fetching latest lazygit version...${NC}"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

if [ -z "$LAZYGIT_VERSION" ]; then
    echo -e "${RED}✗ Failed to fetch latest version${NC}"
    exit 1
fi

echo -e "${BLUE}Latest version: $LAZYGIT_VERSION${NC}"

# Download and install
echo -e "${YELLOW}Downloading lazygit...${NC}"
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
TEMP_DIR=$(mktemp -d)

if curl -fLo "$TEMP_DIR/lazygit.tar.gz" "$LAZYGIT_URL"; then
    echo -e "${GREEN}✓ Downloaded lazygit${NC}"
else
    echo -e "${RED}✗ Failed to download lazygit${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract
echo -e "${YELLOW}Extracting lazygit...${NC}"
tar xf "$TEMP_DIR/lazygit.tar.gz" -C "$TEMP_DIR"

# Install to ~/.local/bin
mkdir -p "$BIN_DIR"
mv "$TEMP_DIR/lazygit" "$BIN_DIR/lazygit"
chmod +x "$BIN_DIR/lazygit"

# Cleanup
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ lazygit installed successfully${NC}"

# Verify installation
if "$BIN_DIR/lazygit" --version >/dev/null 2>&1; then
    LG_VERSION=$("$BIN_DIR/lazygit" --version 2>/dev/null | head -n1)
    echo -e "${GREEN}✓ lazygit is ready${NC}"
    echo -e "${BLUE}Version: $LG_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Note: You may need to restart your terminal or run 'source ~/.zshrc'${NC}"
fi

# ============================================================================
# PHASE 4: CONFIGURE ZSH INTEGRATION
# ============================================================================

echo -e "\n${YELLOW}Phase 4: Configuring Zsh integration...${NC}"

ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
    # Ensure ~/.local/bin is in PATH
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"; then
        echo -e "${YELLOW}Adding ~/.local/bin to PATH...${NC}"
        echo "" >> "$ZSHRC"
        echo "# Add ~/.local/bin to PATH for user binaries" >> "$ZSHRC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
        echo -e "${GREEN}✓ PATH updated${NC}"
    else
        echo -e "${GREEN}✓ PATH already includes ~/.local/bin${NC}"
    fi

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

# ============================================================================
# CLEANUP
# ============================================================================

echo -e "\n${YELLOW}Cleaning up...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove log files if they exist
if [ -f "$SCRIPT_DIR/installation.log" ]; then
    rm -f "$SCRIPT_DIR/installation.log"
    echo -e "${GREEN}✓ Removed installation.log${NC}"
fi

if [ -f "$SCRIPT_DIR/theme-installation.log" ]; then
    rm -f "$SCRIPT_DIR/theme-installation.log"
    echo -e "${GREEN}✓ Removed theme-installation.log${NC}"
fi
