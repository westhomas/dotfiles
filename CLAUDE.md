# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **chezmoi**-managed dotfiles repository for macOS development environments. Chezmoi uses Go templates to generate configuration files, allowing for environment-specific variations (local vs remote) and automated deployment.

## Key Architecture

### Chezmoi Template System

- **File naming**: Files prefixed with `dot_` become `.` files (e.g., `dot_zshrc.tmpl` → `~/.zshrc`)
- **Templates**: Files ending in `.tmpl` are processed as Go templates
- **Remote detection**: `.chezmoi.toml.tmpl` sets `remote` variable based on environment (Codespaces, SSH, Docker, Kubernetes)
- **Auto-commit**: On local machines, chezmoi is configured with `autoCommit = true` and `autoPush = true`

### Tool Management

- **mise**: Primary version manager (replaces asdf). Configured in `dot_config/mise/config.toml.tmpl`
  - Manages CLI tools like neovim, node, fzf, ripgrep, zoxide, etc.
  - Uses lockfile and pinning for reproducibility
- **Homebrew**: macOS package manager for GUI apps and some CLI tools
  - Defined in `dot_Brewfile.tmpl`
  - Only applies when `chezmoi.os == "darwin"`

### Shell Configuration

**dot_zshrc.tmpl** provides:
- Vi mode bindings (`bindkey -v`)
- Starship prompt integration
- Tool initialization: mise, fzf, kubectl, flux, zoxide, atuin
- Aliases: `lsd` for `ls`, `bat` for `cat`, `z` for `cd` (via zoxide)
- History: 50,000 entries with duplicate filtering

### Neovim Configuration

Located in `dot_config/nvim/`:
- LazyVim-based setup with custom plugins
- Key plugins: fzf-lua, telescope, multicursor, conform, lint
- Configured via Lua modules in `lua/config/` and `lua/plugins/`

## Common Commands

### Quick Reference (via Makefile)

```bash
# Initial setup (installs chezmoi and applies dotfiles)
make setup

# Apply dotfiles to home directory
make apply

# Show what would change (dry run)
make diff

# Re-add all modified managed files back to source
make re-add

# Install all tools (mise + Homebrew)
make install-tools

# Update all tools
make update-tools

# Pull latest changes and apply
make update
```

### Managing Dotfiles (Direct chezmoi commands)

```bash
# Apply changes from this repo to home directory
chezmoi apply --source=$(PWD)

# Edit a dotfile (automatically opens in $EDITOR)
chezmoi edit ~/.zshrc

# See what would change (dry run)
chezmoi diff --source=$(PWD)

# Add a new file to chezmoi management
chezmoi add ~/.config/newfile
```

### Tool Installation (Direct commands)

```bash
# Install all mise-managed tools
mise install

# Install Homebrew packages (macOS only)
brew bundle --file=~/.Brewfile

# Update tools
mise upgrade
brew upgrade
```

## Important Notes

- **Source directory**: This repository is the chezmoi source directory
- **Template variables**: Access via `.chezmoi.os`, `.data.remote`, etc.
- **Git integration**: Local environments auto-commit and push chezmoi changes
- **Environment detection**: Remote environments (SSH, containers, Codespaces) are detected automatically
- **Conditional configs**: Use `{{ if eq .chezmoi.os "darwin" }}` for OS-specific settings
