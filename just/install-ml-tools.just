# Install AI/ML development tools via Homebrew
# Part of Atomic-ROCm - AMD GPU compute stack

install-ml-tools:
    #!/usr/bin/env bash
    echo "🤖 Installing AI/ML tools via Homebrew..."
    echo ""

    # Python 3.14 (newer than Fedora 42's 3.13!)
    echo "🐍 Installing Python 3.14..."
    brew install python@3.14

    # Jupyter for notebooks
    echo "📓 Installing JupyterLab..."
    brew install jupyterlab

    # Hugging Face CLI
    echo "🤗 Installing Hugging Face CLI..."
    brew install huggingface-cli

    echo ""
    echo "🔥 Installing PyTorch with ROCm support..."
    /home/linuxbrew/.linuxbrew/bin/pip3 install \
        torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/rocm6.2

    echo ""
    echo "📚 Installing ML libraries..."
    /home/linuxbrew/.linuxbrew/bin/pip3 install \
        transformers \
        datasets \
        accelerate \
        jupyter \
        ipython \
        pandas \
        numpy \
        scipy \
        matplotlib \
        seaborn

    echo ""
    echo "✅ AI/ML tools installed!"
    echo ""
    echo "Installed:"
    echo "  • Python 3.14 (Homebrew)"
    echo "  • JupyterLab"
    echo "  • Hugging Face CLI"
    echo "  • PyTorch with ROCm 6.2 support"
    echo "  • Transformers, datasets, accelerate"
    echo "  • Jupyter, pandas, numpy, scipy, matplotlib"
    echo ""
    echo "💡 Quick test:"
    echo "  python3.14 -c 'import torch; print(torch.cuda.is_available())'"
    echo "  jupyter lab"
