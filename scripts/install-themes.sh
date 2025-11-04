#!/bin/bash

# install-themes.sh - Install Nord-themed desktop environment
# This script installs Graphite GTK theme, Tela circle icons, wallpaper, and GRUB theme

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
ASSETS_DIR="$PROJECT_ROOT/assets"

# Log file
LOG_FILE="$SCRIPT_DIR/theme-installation.log"
> "$LOG_FILE"  # Clear log file

# Parse command line arguments
SKIP_GRUB=false
FORCE_RESOLUTION=""
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-grub)
            SKIP_GRUB=true
            shift
            ;;
        --force-resolution)
            FORCE_RESOLUTION="$2"
            shift 2
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-grub              Skip GRUB theme installation"
            echo "  --force-resolution RES   Force GRUB resolution (1080p/2k/4k)"
            echo "  --yes, -y                Skip all confirmations"
            echo "  --help, -h               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to log messages
log_message() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed (Debian/Ubuntu)
package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

log_message "${MAGENTA}"
log_message "╔════════════════════════════════════════╗"
log_message "║     Nord Theme Installation Setup      ║"
log_message "╚════════════════════════════════════════╝"
log_message "${NC}"
log_message "Started at: $(date '+%Y-%m-%d %H:%M:%S')\n"

# ============================================================================
# PHASE 1: DEPENDENCY CHECK
# ============================================================================

log_message "${CYAN}========================================${NC}"
log_message "${CYAN}Phase 1: Checking Dependencies${NC}"
log_message "${CYAN}========================================${NC}\n"

MISSING_DEPS=()

# Check for essential tools
for cmd in git curl; do
    if ! command_exists "$cmd"; then
        MISSING_DEPS+=("$cmd")
        log_message "${RED}✗ Missing: $cmd${NC}"
    else
        log_message "${GREEN}✓ Found: $cmd${NC}"
    fi
done

# Check for sassc (critical for GTK theme compilation)
if ! command_exists sassc; then
    MISSING_DEPS+=("sassc")
    log_message "${RED}✗ Missing: sassc (required for GTK theme)${NC}"
else
    log_message "${GREEN}✓ Found: sassc${NC}"
fi

# Check for GNOME theme dependencies
if ! package_installed gnome-themes-extra && ! package_installed gnome-themes-standard; then
    MISSING_DEPS+=("gnome-themes-extra")
    log_message "${RED}✗ Missing: gnome-themes-extra${NC}"
else
    log_message "${GREEN}✓ Found: gnome-themes-extra${NC}"
fi

# Check for gtk-update-icon-cache
if ! command_exists gtk-update-icon-cache; then
    MISSING_DEPS+=("libgtk-3-bin")
    log_message "${RED}✗ Missing: gtk-update-icon-cache${NC}"
else
    log_message "${GREEN}✓ Found: gtk-update-icon-cache${NC}"
fi

# Install missing dependencies
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_message "\n${YELLOW}Missing dependencies: ${MISSING_DEPS[*]}${NC}"

    if [ "$AUTO_YES" = false ]; then
        read -p "Install missing dependencies? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_message "${RED}Cannot proceed without dependencies. Exiting.${NC}"
            exit 1
        fi
    fi

    log_message "\n${YELLOW}Installing dependencies...${NC}"
    if sudo apt update && sudo apt install -y "${MISSING_DEPS[@]}"; then
        log_message "${GREEN}✓ Dependencies installed successfully${NC}"
    else
        log_message "${RED}✗ Failed to install dependencies${NC}"
        exit 1
    fi
else
    log_message "\n${GREEN}✓ All dependencies satisfied${NC}"
fi

# ============================================================================
# PHASE 2: DOWNLOAD ASSETS
# ============================================================================

log_message "\n${CYAN}========================================${NC}"
log_message "${CYAN}Phase 2: Downloading Theme Assets${NC}"
log_message "${CYAN}========================================${NC}\n"

# Create assets directory structure
mkdir -p "$ASSETS_DIR/wallpapers"
log_message "${GREEN}✓ Created assets directory: $ASSETS_DIR${NC}\n"

# Download Graphite GTK Theme
log_message "${YELLOW}Downloading Graphite GTK Theme...${NC}"
if [ -d "$ASSETS_DIR/graphite-gtk-theme" ]; then
    log_message "${YELLOW}Repository already exists, pulling latest changes...${NC}"
    cd "$ASSETS_DIR/graphite-gtk-theme"
    if git pull; then
        log_message "${GREEN}✓ Updated Graphite GTK Theme${NC}"
    else
        log_message "${RED}✗ Failed to update Graphite GTK Theme${NC}"
        exit 1
    fi
else
    if git clone https://github.com/vinceliuice/Graphite-gtk-theme.git "$ASSETS_DIR/graphite-gtk-theme"; then
        log_message "${GREEN}✓ Downloaded Graphite GTK Theme${NC}"
    else
        log_message "${RED}✗ Failed to download Graphite GTK Theme${NC}"
        exit 1
    fi
fi

# Remove .git folder
log_message "${YELLOW}Removing .git folder from Graphite GTK Theme...${NC}"
rm -rf "$ASSETS_DIR/graphite-gtk-theme/.git"
log_message "${GREEN}✓ Cleaned up git metadata${NC}\n"

# Download Tela Circle Icon Theme
log_message "${YELLOW}Downloading Tela Circle Icon Theme...${NC}"
if [ -d "$ASSETS_DIR/tela-circle-icon-theme" ]; then
    log_message "${YELLOW}Repository already exists, pulling latest changes...${NC}"
    cd "$ASSETS_DIR/tela-circle-icon-theme"
    if git pull; then
        log_message "${GREEN}✓ Updated Tela Circle Icon Theme${NC}"
    else
        log_message "${RED}✗ Failed to update Tela Circle Icon Theme${NC}"
        exit 1
    fi
else
    if git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$ASSETS_DIR/tela-circle-icon-theme"; then
        log_message "${GREEN}✓ Downloaded Tela Circle Icon Theme${NC}"
    else
        log_message "${RED}✗ Failed to download Tela Circle Icon Theme${NC}"
        exit 1
    fi
fi

# Remove .git folder
log_message "${YELLOW}Removing .git folder from Tela Circle Icon Theme...${NC}"
rm -rf "$ASSETS_DIR/tela-circle-icon-theme/.git"
log_message "${GREEN}✓ Cleaned up git metadata${NC}\n"

# Download wallpaper
log_message "${YELLOW}Downloading Nord wallpaper (wave-Dark-nord)...${NC}"
WALLPAPER_URL="https://raw.githubusercontent.com/vinceliuice/Graphite-gtk-theme/main/wallpaper/wallpapers-nord/wave-Dark-nord.jpg"
if curl -fSL "$WALLPAPER_URL" -o "$ASSETS_DIR/wallpapers/wave-Dark-nord.jpg"; then
    log_message "${GREEN}✓ Downloaded wallpaper${NC}"
else
    log_message "${RED}✗ Failed to download wallpaper${NC}"
    exit 1
fi

log_message "\n${GREEN}✓ All assets downloaded successfully${NC}"

# ============================================================================
# PHASE 3: INSTALL GTK THEME
# ============================================================================

log_message "\n${CYAN}========================================${NC}"
log_message "${CYAN}Phase 3: Installing Graphite GTK Theme${NC}"
log_message "${CYAN}========================================${NC}\n"

cd "$ASSETS_DIR/graphite-gtk-theme"

# Make install script executable
chmod +x install.sh

log_message "${YELLOW}Installing Graphite GTK Theme (Nord variant) system-wide...${NC}"
log_message "${BLUE}This may take a few minutes as it compiles SCSS to CSS...${NC}"
log_message "${YELLOW}You may be prompted for your sudo password...${NC}\n"

if sudo ./install.sh --tweaks nord --dest /usr/share/themes 2>&1 | tee -a "$LOG_FILE"; then
    log_message "\n${GREEN}✓ Graphite GTK Theme installed successfully to /usr/share/themes${NC}"
else
    log_message "${RED}✗ Failed to install Graphite GTK Theme${NC}"
    exit 1
fi

# ============================================================================
# PHASE 4: INSTALL ICON THEME
# ============================================================================

log_message "\n${CYAN}========================================${NC}"
log_message "${CYAN}Phase 4: Installing Tela Circle Icons${NC}"
log_message "${CYAN}========================================${NC}\n"

cd "$ASSETS_DIR/tela-circle-icon-theme"

# Make install script executable
chmod +x install.sh

log_message "${YELLOW}Installing Tela Circle Icon Theme (Nord variant) system-wide...${NC}"
log_message "${YELLOW}You may be prompted for your sudo password...${NC}\n"

if sudo ./install.sh nord -d /usr/share/icons 2>&1 | tee -a "$LOG_FILE"; then
    log_message "\n${GREEN}✓ Tela Circle Icon Theme installed successfully to /usr/share/icons${NC}"
else
    log_message "${RED}✗ Failed to install Tela Circle Icon Theme${NC}"
    exit 1
fi

# ============================================================================
# PHASE 5: INSTALL WALLPAPER
# ============================================================================

log_message "\n${CYAN}========================================${NC}"
log_message "${CYAN}Phase 5: Setting Up Wallpaper${NC}"
log_message "${CYAN}========================================${NC}\n"

# Create backgrounds directory
mkdir -p "$HOME/.local/share/backgrounds"

# Copy wallpaper
log_message "${YELLOW}Copying wallpaper to backgrounds directory...${NC}"
if cp "$ASSETS_DIR/wallpapers/wave-Dark-nord.jpg" "$HOME/.local/share/backgrounds/"; then
    log_message "${GREEN}✓ Wallpaper copied${NC}"
else
    log_message "${RED}✗ Failed to copy wallpaper${NC}"
    exit 1
fi

# Set wallpaper (for GNOME)
if command_exists gsettings; then
    log_message "${YELLOW}Setting wallpaper as desktop background...${NC}"
    WALLPAPER_PATH="file://$HOME/.local/share/backgrounds/wave-Dark-nord.jpg"

    if gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_PATH"; then
        log_message "${GREEN}✓ Wallpaper set (light mode)${NC}"
    fi

    if gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_PATH"; then
        log_message "${GREEN}✓ Wallpaper set (dark mode)${NC}"
    fi
else
    log_message "${YELLOW}⚠ gsettings not found. You may need to set the wallpaper manually.${NC}"
fi

# ============================================================================
# PHASE 6: INSTALL GRUB THEME (OPTIONAL)
# ============================================================================

if [ "$SKIP_GRUB" = false ]; then
    log_message "\n${CYAN}========================================${NC}"
    log_message "${CYAN}Phase 6: Installing GRUB Theme${NC}"
    log_message "${CYAN}========================================${NC}\n"

    log_message "${YELLOW}GRUB theme installation requires sudo privileges.${NC}"
    log_message "${YELLOW}This will modify your bootloader configuration.${NC}\n"

    if [ "$AUTO_YES" = false ]; then
        read -p "Install GRUB theme? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_message "${YELLOW}⊙ Skipping GRUB theme installation${NC}"
        else
            # Detect screen resolution
            if [ -n "$FORCE_RESOLUTION" ]; then
                SCREEN_VARIANT="$FORCE_RESOLUTION"
                log_message "${BLUE}Using forced resolution: $SCREEN_VARIANT${NC}"
            elif command_exists xrandr; then
                log_message "${YELLOW}Detecting screen resolution...${NC}"
                RESOLUTION=$(xrandr 2>/dev/null | grep '\*' | awk '{print $1}' | head -n1)

                if [[ "$RESOLUTION" == "3840x2160" ]] || [[ "$RESOLUTION" == "3840"* ]]; then
                    SCREEN_VARIANT="4k"
                elif [[ "$RESOLUTION" == "2560x1440" ]] || [[ "$RESOLUTION" == "2560"* ]]; then
                    SCREEN_VARIANT="2k"
                else
                    SCREEN_VARIANT="1080p"
                fi

                log_message "${GREEN}✓ Detected resolution: $RESOLUTION → $SCREEN_VARIANT${NC}"
            else
                SCREEN_VARIANT="1080p"
                log_message "${YELLOW}⚠ Could not detect resolution, defaulting to $SCREEN_VARIANT${NC}"
            fi

            # Install GRUB theme
            cd "$ASSETS_DIR/graphite-gtk-theme/other/grub2"
            chmod +x install.sh

            log_message "\n${YELLOW}Installing GRUB theme (Nord variant, $SCREEN_VARIANT)...${NC}"
            log_message "${YELLOW}You may be prompted for your sudo password...${NC}\n"

            if sudo ./install.sh -t nord -s "$SCREEN_VARIANT" 2>&1 | tee -a "$LOG_FILE"; then
                log_message "\n${GREEN}✓ GRUB theme installed successfully${NC}"
            else
                log_message "${RED}✗ Failed to install GRUB theme${NC}"
                log_message "${YELLOW}Your system is still bootable, but the GRUB theme was not applied.${NC}"
            fi
        fi
    fi
else
    log_message "\n${YELLOW}⊙ Skipping GRUB theme installation (--skip-grub flag)${NC}"
fi

# ============================================================================
# SUMMARY
# ============================================================================

log_message "\n${MAGENTA}========================================${NC}"
log_message "${MAGENTA}INSTALLATION COMPLETE!${NC}"
log_message "${MAGENTA}========================================${NC}\n"

log_message "${GREEN}✓ Graphite GTK Theme (Nord) installed${NC}"
log_message "${GREEN}✓ Tela Circle Icons (Nord) installed${NC}"
log_message "${GREEN}✓ Nord wallpaper set${NC}"

if [ "$SKIP_GRUB" = false ]; then
    log_message "${GREEN}✓ GRUB theme installation attempted${NC}"
fi

log_message "\n${CYAN}Next Steps:${NC}"
log_message "1. Open GNOME Tweaks to apply the theme:"
log_message "   - Appearance → Themes → Applications: ${CYAN}Graphite-nord-dark${NC}"
log_message "   - Appearance → Themes → Icons: ${CYAN}Tela-circle-nord${NC}"
log_message ""
log_message "2. Log out and log back in for full effect"
log_message ""
log_message "3. If you installed the GRUB theme, reboot to see it"
log_message ""
log_message "${BLUE}Full log saved to: $LOG_FILE${NC}"
log_message "\nCompleted at: $(date '+%Y-%m-%d %H:%M:%S')"
