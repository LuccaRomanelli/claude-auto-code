#!/bin/bash
set -e

echo "==> Setting up development environment..."

# Ensure Homebrew and mise are available
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Trust mise config if present
if [ -f "mise.toml" ]; then
    echo "==> Trusting mise.toml..."
    mise trust
fi
eval "$(mise activate bash)"

# Clone and setup dotfiles with stow
DOTFILES_REPO="https://github.com/LuccaRomanelli/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "==> Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "==> Dotfiles already exist, pulling latest..."
    cd "$DOTFILES_DIR" && git pull && cd -
fi

# Apply dotfiles using stow
echo "==> Applying dotfiles with stow..."
cd "$DOTFILES_DIR"

# Remove conflicting files created by oh-my-zsh before stowing
rm -f "$HOME/.zshrc" 2>/dev/null || true

# Stow each package directory (common convention: each subdirectory is a stow package)
for package in */; do
    package_name="${package%/}"
    # Skip hidden directories, non-stow dirs, and platform-specific packages
    if [[ "$package_name" != .* ]] && [[ "$package_name" != "README"* ]] && \
       [[ "$package_name" != "ghostty" ]] && [[ "$package_name" != "waybar" ]]; then
        echo "    Stowing $package_name..."
        stow -v --restow "$package_name" 2>/dev/null || echo "    Warning: Could not stow $package_name"
    fi
done
cd -

# Install tmux plugins via TPM
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "==> Installing tmux plugins..."
    ~/.tmux/plugins/tpm/bin/install_plugins || true
fi

# Set up XCompose if config exists
if [ -f "$HOME/.XCompose" ]; then
    echo "==> XCompose configuration found"
fi

# Install project-specific dependencies
echo "==> Running project-specific setup..."
source .devcontainer/project-dependencies.sh

# Change default shell to zsh
if [ -f /home/linuxbrew/.linuxbrew/bin/zsh ]; then
    echo "==> Setting zsh as default shell..."
    sudo chsh -s /home/linuxbrew/.linuxbrew/bin/zsh dev 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "  Development environment ready!"
echo "=========================================="
echo ""
echo "Available commands:"
echo "  python start.py        - Launch CLI menu"
echo "  cd ui && npm run dev   - Start UI dev server"
echo "  claude /login          - Authenticate Claude Code"
echo "  yazi                   - Terminal file manager"
echo "  tmux                   - Terminal multiplexer"
echo ""
