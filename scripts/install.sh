#!/bin/bash

# install.sh - Main installation orchestrator
# This script runs all installation subscripts and provides comprehensive logging

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Log file
LOG_FILE="$SCRIPT_DIR/installation.log"
> "$LOG_FILE"  # Clear log file

# Arrays to track success and failures
declare -a SUCCESSFUL_INSTALLS
declare -a FAILED_INSTALLS
declare -a SKIPPED_INSTALLS

# Function to log messages
log_message() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to run a script and track its status
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    local display_name="$2"

    log_message "\n${BLUE}========================================${NC}"
    log_message "${BLUE}Running: $display_name${NC}"
    log_message "${BLUE}========================================${NC}"

    if [ ! -f "$script_path" ]; then
        log_message "${RED}✗ Script not found: $script_path${NC}"
        FAILED_INSTALLS+=("$display_name (script not found)")
        return 1
    fi

    # Make script executable
    chmod +x "$script_path"

    # Run the script and capture output
    if bash "$script_path" 2>&1 | tee -a "$LOG_FILE"; then
        log_message "${GREEN}✓ SUCCESS: $display_name${NC}"
        SUCCESSFUL_INSTALLS+=("$display_name")
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            log_message "${YELLOW}⊙ SKIPPED: $display_name${NC}"
            SKIPPED_INSTALLS+=("$display_name")
            return 0
        else
            log_message "${RED}✗ FAILED: $display_name (Exit code: $exit_code)${NC}"
            FAILED_INSTALLS+=("$display_name")
            return 1
        fi
    fi
}

# Function to print summary
print_summary() {
    log_message "\n${MAGENTA}========================================"
    log_message "INSTALLATION SUMMARY"
    log_message "========================================${NC}"

    # Successful installations
    if [ ${#SUCCESSFUL_INSTALLS[@]} -gt 0 ]; then
        log_message "\n${GREEN}✓ Successful (${#SUCCESSFUL_INSTALLS[@]}):${NC}"
        for item in "${SUCCESSFUL_INSTALLS[@]}"; do
            log_message "  ${GREEN}✓${NC} $item"
        done
    fi

    # Skipped installations
    if [ ${#SKIPPED_INSTALLS[@]} -gt 0 ]; then
        log_message "\n${YELLOW}⊙ Skipped (${#SKIPPED_INSTALLS[@]}):${NC}"
        for item in "${SKIPPED_INSTALLS[@]}"; do
            log_message "  ${YELLOW}⊙${NC} $item"
        done
    fi

    # Failed installations
    if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
        log_message "\n${RED}✗ Failed (${#FAILED_INSTALLS[@]}):${NC}"
        for item in "${FAILED_INSTALLS[@]}"; do
            log_message "  ${RED}✗${NC} $item"
        done
    fi

    log_message "\n${MAGENTA}========================================${NC}"
    log_message "${BLUE}Total: $((${#SUCCESSFUL_INSTALLS[@]} + ${#FAILED_INSTALLS[@]} + ${#SKIPPED_INSTALLS[@]})) | "
    log_message "Success: ${#SUCCESSFUL_INSTALLS[@]} | "
    log_message "Skipped: ${#SKIPPED_INSTALLS[@]} | "
    log_message "Failed: ${#FAILED_INSTALLS[@]}${NC}"
    log_message "${MAGENTA}========================================${NC}"
    log_message "\n${BLUE}Full log saved to: $LOG_FILE${NC}\n"
}

# Main installation flow
main() {
    log_message "${MAGENTA}"
    log_message "╔════════════════════════════════════════╗"
    log_message "║   Fresh Ubuntu Setup - Installation   ║"
    log_message "║        Starting Installation...        ║"
    log_message "╚════════════════════════════════════════╝"
    log_message "${NC}"
    log_message "Started at: $(date '+%Y-%m-%d %H:%M:%S')\n"

    # Check if running on Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log_message "${YELLOW}Warning: This script is designed for Ubuntu.${NC}"
        log_message "${YELLOW}Your system: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_message "${RED}Installation cancelled.${NC}"
            exit 1
        fi
    fi

    # Run installation scripts in order
    run_script "essentials.sh" "Essential Tools (curl, wget, git)"
    run_script "zsh.sh" "Zsh with Oh My Zsh & Powerlevel10k"
    run_script "dev-tools.sh" "Development Tools (fzf, neovim, lazygit)"
    run_script "chrome.sh" "Google Chrome"
    run_script "vscode.sh" "Visual Studio Code"
    run_script "nodejs.sh" "Node.js"
    run_script "gnome-tools.sh" "GNOME Tools (Tweaks & Extensions)"

    # Theme installation (optional)
    echo -e "\n${YELLOW}NOTE: Theme installation will set up Nord-themed desktop environment.${NC}"
    echo -e "${YELLOW}This includes GTK theme, icons, wallpaper, and optionally GRUB theme.${NC}"
    read -p "Do you want to install Nord themes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "install-themes.sh" "Nord Theme Setup"
    else
        log_message "${YELLOW}⊙ SKIPPED: Nord Theme Setup (user choice)${NC}"
        SKIPPED_INSTALLS+=("Nord Theme Setup")
    fi

    # Ghostty takes longest, so run it last
    echo -e "\n${YELLOW}NOTE: Ghostty installation requires building from source and may take 10-15 minutes.${NC}"
    read -p "Do you want to install Ghostty? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_script "ghostty.sh" "Ghostty Terminal"
    else
        log_message "${YELLOW}⊙ SKIPPED: Ghostty Terminal (user choice)${NC}"
        SKIPPED_INSTALLS+=("Ghostty Terminal")
    fi

    # Print summary
    print_summary

    # Exit with appropriate code
    if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
        log_message "${RED}Installation completed with errors.${NC}"
        exit 1
    else
        log_message "${GREEN}Installation completed successfully!${NC}"
        exit 0
    fi
}

# Run main function
main "$@"
