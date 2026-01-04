# Install essential CLI tools via Homebrew
# Part of Atomic-ROCm - Cloud-native package management

install-brew-essentials:
    #!/usr/bin/env bash
    echo "🍺 Installing essential Homebrew packages..."
    echo ""

    # Modern CLI replacements (Rust-based, fast!)
    echo "📦 Installing modern CLI tools..."
    brew install \
        ripgrep \
        fd \
        bat \
        exa \
        zoxide \
        fzf \
        starship

    # Development tools
    echo "🔧 Installing development tools..."
    brew install \
        git \
        gh \
        lazygit \
        neovim \
        helix \
        tmux

    # System monitoring
    echo "📊 Installing system monitoring tools..."
    brew install \
        htop \
        btop \
        nvtop \
        ncdu \
        duf \
        dust

    # Build tools
    echo "🔨 Installing build tools..."
    brew install \
        cmake \
        ninja \
        ccache

    echo ""
    echo "✅ Homebrew essentials installed!"
    echo ""
    echo "Installed tools:"
    echo "  • Modern CLI: ripgrep, fd, bat, exa, zoxide, fzf, starship"
    echo "  • Dev tools: git, gh, lazygit, neovim, helix, tmux"
    echo "  • Monitoring: htop, btop, nvtop, ncdu, duf, dust"
    echo "  • Build: cmake, ninja, ccache"
    echo ""
    echo "💡 Tip: Run 'starship init bash >> ~/.bashrc' to enable the pretty prompt!"
