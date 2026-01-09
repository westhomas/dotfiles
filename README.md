# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) for macOS development environments.

## What's Included

- **Shell configuration**: zsh with vi-mode, starship prompt, and extensive aliases
- **Tool management**: mise for CLI tools, Homebrew for macOS applications
- **Editor**: Neovim with LazyVim configuration
- **Git**: Custom aliases, diff-so-fancy integration, and auto-rebase
- **Development tools**: fzf, ripgrep, bat, lsd, zoxide, atuin, and more
- **Environment detection**: Automatically adapts configuration for local vs remote (SSH, containers, Codespaces)

## Quick Start

### Initial Setup

Clone this repository and run the setup script:

```bash
git clone https://github.com/westhomas/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
make setup
```

This will:
1. Install or use existing chezmoi
2. Apply all dotfiles to your home directory
3. Install Homebrew packages (on macOS)

### Daily Usage

```bash
# Apply any changes you've made in this repo
make apply

# See what would change before applying
make diff

# Pull latest changes and apply
make update

# Install all tools defined in mise config
make install-tools

# Update all tools
make update-tools
```

## How It Works

### Chezmoi Template System

This repository uses [chezmoi](https://www.chezmoi.io/) to manage dotfiles with templating support:

- Files prefixed with `dot_` become hidden files (e.g., `dot_zshrc.tmpl` → `~/.zshrc`)
- Files ending in `.tmpl` are processed as Go templates
- Environment detection automatically adapts configs for remote vs local machines
- On local machines, changes are auto-committed and pushed

### Tool Management

- **[mise](https://mise.jdx.dev/)**: Manages CLI tools and their versions (replaces asdf)
  - Configuration: `dot_config/mise/config.toml.tmpl`
  - Tools: neovim, node, fzf, ripgrep, zoxide, atuin, and more

- **Homebrew**: Manages macOS applications
  - Configuration: `dot_Brewfile.tmpl`
  - Apps: iTerm2, WezTerm, Visual Studio Code, Chrome, etc.

## Adding New Files

To add a new dotfile to chezmoi management:

```bash
# Add a file
chezmoi add ~/.config/newfile

# Add a template (for files that need environment-specific content)
chezmoi add --template ~/.config/newfile
```

The file will be copied to this repository with the appropriate `dot_` prefix.

## Editing Dotfiles

### Option 1: Edit in this repository

```bash
# Edit files directly in ~/code/dotfiles
vim dot_zshrc.tmpl

# Apply changes
make apply
```

### Option 2: Use chezmoi edit

```bash
# Opens the source file in your $EDITOR
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply
```

## Customization

### Shell Configuration

- **dot_zshrc.tmpl**: Main zsh configuration
- **dot_bashrc.tmpl**: Bash configuration (if needed)
- **dot_config/starship.toml**: Prompt customization

### Git Configuration

- **dot_gitconfig**: Git aliases and settings
- **dot_gitconfig.ecl**: Personal git config (name, email)

### Tool Versions

Edit `dot_config/mise/config.toml.tmpl` to change tool versions:

```toml
[tools]
neovim = "0.11.5"
node = "23.11.0"
# Add more tools as needed
```

## Prerequisites

- macOS (for full functionality)
- Git (usually pre-installed)
- Internet connection (for initial setup)

The setup script will automatically install chezmoi if not present.

## Key Features

### Shell Enhancements

- **Vi mode**: Full vi keybindings in zsh
- **Smart aliases**: `ll` (lsd -algh), `cat` → `bat`, `cd` → `z` (zoxide)
- **Starship prompt**: Fast, customizable shell prompt
- **History**: 50,000 entries with duplicate filtering
- **Auto-completion**: kubectl, flux, and more

### Git Aliases

```bash
git vlog          # Visual log with graph
git st            # Status
git co            # Checkout
git undo          # Undo last commit (soft reset)
git forcepull     # Stash, pull --rebase, pop stash
```

See `dot_gitconfig` for the full list.

## Directory Structure

```
.
├── Makefile                          # Quick commands
├── setup                             # Initial setup script
├── .chezmoi.toml.tmpl               # Chezmoi configuration
├── dot_zshrc.tmpl                   # Zsh configuration
├── dot_gitconfig                    # Git configuration
├── dot_Brewfile.tmpl                # Homebrew packages
├── dot_config/
│   ├── mise/config.toml.tmpl       # Tool versions
│   ├── starship.toml               # Prompt config
│   ├── nvim/                       # Neovim configuration
│   └── zellij/                     # Terminal multiplexer
└── CLAUDE.md                        # AI assistant guidance
```

## Troubleshooting

### Changes not applying

```bash
# Check what chezmoi would do
make diff

# Force apply
make apply
```

### Tool not found after installation

```bash
# Reload shell configuration
source ~/.zshrc

# Or restart your terminal
```

### Mise tools not installing

```bash
# Update mise itself first
mise self-update

# Then install tools
mise install
```

## License

Personal dotfiles - use at your own risk and customize to your needs.
