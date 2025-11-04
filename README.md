# Fresh Ubuntu Setup

Automated setup scripts for quickly configuring a fresh Ubuntu installation. This repository contains scripts to install essential development tools and applications, plus dotfiles for consistent configuration across machines.

## Structure

```
fresh-ubuntu-setup/
├── scripts/                  # Installation scripts
│   ├── install.sh           # Main orchestrator (run this)
│   ├── essentials.sh        # curl, wget, git
│   ├── zsh.sh               # Zsh + Oh My Zsh + Powerlevel10k
│   ├── dev-tools.sh         # fzf, neovim, LazyVim, lazygit
│   ├── chrome.sh            # Google Chrome
│   ├── vscode.sh            # Visual Studio Code
│   ├── nodejs.sh            # Node.js (LTS)
│   ├── gnome-tools.sh       # GNOME Tweaks & Extensions
│   ├── install-themes.sh    # Nord theme setup
│   └── ghostty.sh           # Ghostty terminal
├── assets/                   # Theme assets (populated by scripts)
│   ├── fonts/
│   │   └── MesloLGS/        # Nerd Fonts for terminal
│   ├── graphite-gtk-theme/  # (downloaded by install-themes.sh)
│   ├── tela-circle-icon-theme/
│   └── wallpapers/
└── dotfiles/                 # Your configuration files
```

## Quick Start

### Clone and Run

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/fresh-ubuntu-setup.git
cd fresh-ubuntu-setup

# Run the main installation script
./scripts/install.sh
```

That's it! The script will install everything and provide a detailed summary.

## Installation Order

The main installer runs scripts in this optimized order:

1. **essentials.sh** - Core tools (git required for subsequent steps)
2. **zsh.sh** - Shell setup (ensures other tools configure .zshrc correctly)
3. **dev-tools.sh** - CLI development tools
4. **chrome.sh** - Web browser
5. **vscode.sh** - Code editor
6. **nodejs.sh** - JavaScript runtime
7. **gnome-tools.sh** - Desktop environment customization
8. **install-themes.sh** - Nord theme setup (optional, prompted)
9. **ghostty.sh** - Terminal emulator (optional, prompted)

## What Gets Installed

### Essential Tools
- **curl** - Command-line tool for transferring data
- **wget** - Network downloader
- **git** - Version control system

### Development Tools
- **Google Chrome** - Web browser (latest stable)
- **Visual Studio Code** - Code editor (latest)
- **Node.js** - JavaScript runtime (LTS version)

### Shell & Terminal
- **Zsh** - Advanced shell with powerful features
- **Oh My Zsh** - Framework for managing Zsh configuration
- **Powerlevel10k** - Feature-rich prompt theme
- **MesloLGS NF Fonts** - Powerline-compatible fonts for terminal
- **Zsh Plugins**:
  - git - Git aliases and functions
  - zsh-autosuggestions - Fish-like autosuggestions
  - web-search - Search from terminal
  - history - Enhanced history commands
  - jsontools - JSON manipulation tools
  - fzf - Fuzzy finder integration

### CLI Development Tools
- **fzf** - Fuzzy finder for files, commands, and history
- **Neovim** - Modern, extensible text editor (latest stable)
- **LazyVim** - Pre-configured Neovim distribution with:
  - LSP (Language Server Protocol) for intelligent code completion
  - Treesitter for advanced syntax highlighting
  - Telescope fuzzy finder integration
  - Neo-tree file explorer
  - Auto-completion and snippets
  - Git integration (gitsigns, lazygit)
  - Which-key for keybinding discovery
  - Beautiful UI with statusline and themes
- **lazygit** - Terminal UI for Git commands
- **Integrations**:
  - fzf keybindings (Ctrl+R, Ctrl+T, Alt+C)
  - vim/vi aliased to nvim
  - lg aliased to lazygit
  - LazyVim + lazygit built-in (`<Space>gg` in nvim)

### Desktop Environment
- **GNOME Tweaks** - Desktop customization tool
- **GNOME Extensions** - Shell extensions support
- **Extension Manager** - Manage GNOME extensions
- **Custom Extensions** - 5 pre-installed extensions:
  - Blur my Shell
  - Dash to Dock
  - User Themes
  - System Monitor
  - Unblank Lock Screen

### Theming (Optional)
- **Graphite GTK Theme (Nord)** - Beautiful Nord-themed GTK theme
- **Tela Circle Icons (Nord)** - Circular icon theme with Nord colors
- **Nord Wallpaper** - Wave-Dark-nord wallpaper
- **Graphite GRUB Theme (Nord)** - Themed bootloader (optional)

### Optional
- **Ghostty Terminal** - Modern GPU-accelerated terminal (requires building from source)

## Running Individual Scripts

You can run individual installation scripts if you only need specific tools:

```bash
# Install just the essentials
./scripts/essentials.sh

# Install only VSCode
./scripts/vscode.sh

# Install only Chrome
./scripts/chrome.sh

# Install only Node.js
./scripts/nodejs.sh

# Install GNOME tools (includes 5 custom extensions)
./scripts/gnome-tools.sh

# Install Zsh with Oh My Zsh and Powerlevel10k
./scripts/zsh.sh

# Install CLI dev tools (fzf, neovim, lazygit)
./scripts/dev-tools.sh

# Install Nord themes (GTK theme, icons, wallpaper, GRUB)
./scripts/install-themes.sh

# Install Ghostty (takes 10-15 minutes)
./scripts/ghostty.sh
```

## Quick Reference

### LazyVim Keybindings (Leader = Space)
```
<Space>ff    - Find files (Telescope)
<Space>fg    - Live grep (search in files)
<Space>fb    - Find buffers
<Space>e     - Toggle file explorer (Neo-tree)
<Space>gg    - Open lazygit
<Space>l     - Open Lazy plugin manager
<Space>x     - LazyVim extras (install language support)
<Space>qq    - Quit all
```

### fzf Keybindings
```
Ctrl+R       - Search command history
Ctrl+T       - Search files in current directory
Alt+C        - Change directory with fuzzy search
vim $(fzf)   - Open file in vim with fuzzy finder
```

### lazygit
```
lg           - Launch lazygit (alias)
<Space>gg    - Open lazygit from Neovim
```

### Zsh Aliases
```
vim          - Opens Neovim (alias)
vi           - Opens Neovim (alias)
lg           - Opens lazygit (alias)
```

## Features

### Error Handling
- Each script has comprehensive error checking
- Installation continues even if one component fails
- Clear error messages indicate what went wrong

### Logging
- All output is logged during installation
- Log files are automatically cleaned up after successful installation
- If needed for debugging, logs are at:
  - `scripts/installation.log` (main installation)
  - `scripts/theme-installation.log` (theme installation)

### Summary Report
After installation, you'll see a summary showing:
- ✓ Successfully installed components
- ⊙ Skipped components (already installed)
- ✗ Failed components (with reasons)

### Example Output

```
========================================
INSTALLATION SUMMARY
========================================

✓ Successful (8):
  ✓ Essential Tools (curl, wget, git)
  ✓ Zsh with Oh My Zsh & Powerlevel10k
  ✓ Development Tools (fzf, neovim, lazygit)
  ✓ Google Chrome
  ✓ Visual Studio Code
  ✓ Node.js
  ✓ GNOME Tools (Tweaks & Extensions)
  ✓ Nord Theme Setup

⊙ Skipped (1):
  ⊙ Ghostty Terminal (user choice)

✗ Failed (0):

========================================
Total: 9 | Success: 8 | Skipped: 1 | Failed: 0
========================================

Full log saved to: /home/user/fresh-ubuntu-setup/scripts/installation.log
```

## Requirements

- Ubuntu 20.04 or later (may work on other Debian-based distributions)
- Internet connection
- sudo privileges

## Troubleshooting

### Script fails with permission error
Make sure the scripts are executable:
```bash
chmod +x scripts/*.sh
```

### Installation fails for a specific component
1. Check the log files if they still exist (cleaned up on success)
2. Run that specific script individually to see detailed errors
3. Ensure your package lists are up to date: `sudo apt update`

### Neovim or lazygit not found after installation
The binaries are installed to `~/.local/bin/`. If they're not found:
1. Restart your terminal, or
2. Run `source ~/.zshrc` to reload your shell configuration
3. Verify PATH includes `~/.local/bin`: `echo $PATH`

### Ghostty build fails
Ghostty requires building from source and has specific dependencies:
- Zig compiler (installed automatically)
- GTK4 and libadwaita
- Build tools (gcc, make, etc.)

If the build fails, check:
- You have enough disk space (at least 2GB free)
- All dependencies are installed
- Your system is up to date

## Customization

### Adding More Scripts
1. Create a new script in `scripts/` directory
2. Follow the same structure as existing scripts (error handling, colors, etc.)
3. Add it to `install.sh` in the main() function

### Modifying Installation Order
Edit `scripts/install.sh` and reorder the `run_script` calls in the `main()` function.

## Dotfiles & Configuration

### Automatic Configuration
The installation scripts automatically configure:
- **Zsh** - `.zshrc` with Powerlevel10k theme and plugins
- **Neovim** - `~/.config/nvim/` with LazyVim starter
- **GNOME** - Extensions installed and ready to enable
- **Fonts** - MesloLGS Nerd Fonts installed system-wide

### Custom Dotfiles
The `dotfiles/` directory is for your personal configuration files. You can add:
- Shell configurations (.bashrc, .zshrc customizations)
- Git config (.gitconfig)
- Editor configs (additional nvim plugins, settings)
- Terminal themes and color schemes
- Custom fonts or additional Nerd Fonts
- Application-specific configs

All existing configurations are backed up with timestamps before modifications.

## Contributing

Feel free to add more installation scripts or improve existing ones!

## License

MIT License - Feel free to use and modify as needed.

## Installation Notes

### Automatic vs Interactive
- **Automatic installations**: essentials, zsh, dev-tools, chrome, vscode, nodejs, gnome-tools
- **Interactive prompts**: Nord themes, Ghostty (due to longer installation time)

### Key Details
- **Chrome & VSCode**: Downloaded directly from official sources
- **Node.js**: Installed from NodeSource repository (latest LTS)
- **Neovim**: Installed as AppImage (latest stable v0.11.5+) to `~/.local/bin/`
- **lazygit**: Installed from GitHub releases (latest version) to `~/.local/bin/`
- **LazyVim**: First launch takes 2-3 minutes to install all plugins automatically
- **GNOME Extensions**: Installed system-wide, requires logout to activate
- **Nord Themes**: Downloads ~20MB of assets, GRUB installation requires sudo
- **Ghostty**: Builds from source, takes 10-15 minutes, requires 2GB+ free space
- **Zsh**: Automatically set as default shell (logout required to take effect)
- **Fonts**: MesloLGS Nerd Fonts installed for terminal, Neovim, and Powerlevel10k
- **PATH**: `~/.local/bin` is automatically added to PATH for user-installed binaries

### Safety Features
- All scripts check if software is already installed (idempotent)
- Existing configs are backed up with timestamps (e.g., .zshrc.backup, nvim.backup.*)
- Installation continues even if individual components fail
- Comprehensive logging during installation
- Log files automatically cleaned up on successful completion
- No broken PPAs - uses AppImages and direct downloads for compatibility

### Post-Installation
1. **Log out and log back in** (for Zsh and GNOME extensions)
2. **Launch Neovim** (`nvim`) - First launch installs LazyVim plugins
3. **Configure Powerlevel10k** - Wizard runs automatically on first Zsh launch
4. **Apply themes** - Use GNOME Tweaks to select Graphite-nord-dark and Tela-circle-nord
5. **Reboot** (if GRUB theme was installed)

---

**Happy Hacking!** 🚀
