# Set up ROCm development environment
# Part of Atomic-ROCm - AMD GPU compute workspace

setup-rocm-dev:
    #!/usr/bin/env bash
    echo "🚀 Setting up ROCm development environment..."
    echo ""

    # Install build tools via Homebrew
    echo "🔨 Installing build tools..."
    brew install cmake ninja ccache git

    # Create development workspace
    echo "📁 Creating ROCm-Projects workspace..."
    mkdir -p ~/ROCm-Projects
    mkdir -p ~/ROCm-Projects/builds
    mkdir -p ~/ROCm-Projects/models
    mkdir -p ~/ROCm-Projects/notebooks

    # Verify ROCm installation
    echo ""
    echo "🔍 Verifying ROCm installation..."
    if [ -f /opt/rocm/bin/rocminfo ]; then
        /opt/rocm/bin/rocminfo | grep -A 5 "Agent"
    else
        echo "⚠️  ROCm not found at /opt/rocm"
    fi

    echo ""
    if [ -f /opt/rocm/bin/rocm-smi ]; then
        /opt/rocm/bin/rocm-smi --showdriverversion
        /opt/rocm/bin/rocm-smi --showproductname
    else
        echo "⚠️  rocm-smi not found"
    fi

    # Create helpful aliases
    echo ""
    echo "📝 Adding ROCm aliases to ~/.bashrc..."
    cat >> ~/.bashrc << 'ALIASES'

# ROCm Development Aliases
alias rocm-info='rocminfo | grep -A 5 "Agent"'
alias rocm-gpu='rocm-smi --showproductname && rocm-smi --showmeminfo vram'
alias rocm-temp='watch -n 1 rocm-smi --showtemp'
alias rocm-power='watch -n 1 rocm-smi --showpower'
alias rocm-usage='watch -n 1 rocm-smi --showuse'
ALIASES

    echo ""
    echo "✅ ROCm development environment ready!"
    echo ""
    echo "Workspace created at:"
    echo "  ~/ROCm-Projects/"
    echo "  ├── builds/      - For building from source"
    echo "  ├── models/      - For AI models"
    echo "  └── notebooks/   - For Jupyter notebooks"
    echo ""
    echo "🔧 Helpful commands added:"
    echo "  rocm-info    - Show GPU info"
    echo "  rocm-gpu     - Show GPU name and VRAM"
    echo "  rocm-temp    - Monitor temperature"
    echo "  rocm-power   - Monitor power usage"
    echo "  rocm-usage   - Monitor GPU utilization"
    echo ""
    echo "💡 Reload shell: source ~/.bashrc"
