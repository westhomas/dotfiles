.PHONY: help setup apply diff re-add install-tools update-tools update install-vscode-extensions

# Default target
help:
	@echo "Available targets:"
	@echo "  make setup         - Run initial setup (installs chezmoi and applies dotfiles)"
	@echo "  make apply         - Apply dotfiles to home directory"
	@echo "  make diff          - Show what would change (dry run)"
	@echo "  make re-add        - Re-add all modified managed files back to source"
	@echo "  make install-tools - Install mise and Homebrew tools"
	@echo "  make update-tools  - Update all tools (mise and brew)"
	@echo "  make update        - Git pull and apply changes"
	@echo "  make install-vscode-extensions - Install VS Code extensions"

# Run the setup script
setup:
	./setup

# Apply dotfiles from this source directory
apply:
	chezmoi apply --source=$(PWD)

# Re-add all modified managed files back to source
re-add:
	chezmoi re-add --source=$(PWD)

# Show what would change
diff:
	chezmoi diff --source=$(PWD)

# Install all tools
install-tools:
	@echo "Installing mise tools..."
	@command -v mise >/dev/null && mise install || echo "mise not found, run 'make setup' first"
	@echo "Installing Homebrew packages..."
	@command -v brew >/dev/null && test -f "$$HOME/.Brewfile" && brew bundle --file="$$HOME/.Brewfile" || echo "Homebrew or .Brewfile not found"

# Update all tools
update-tools:
	@echo "Updating mise tools..."
	@command -v mise >/dev/null && mise upgrade || echo "mise not found"
	@echo "Updating Homebrew packages..."
	@command -v brew >/dev/null && brew upgrade || echo "Homebrew not found"

# Install VS Code extensions
install-vscode-extensions:
	@command -v code >/dev/null || { echo "VS Code CLI (code) not found"; exit 1; }
	@echo "Installing VS Code extensions..."
	@cat "$$HOME/.config/Code/extensions.txt" | xargs -L1 code --install-extension

# Pull latest changes and apply
update:
	git pull
	$(MAKE) apply
