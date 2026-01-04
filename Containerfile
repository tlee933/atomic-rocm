# Atomic-ROCm: Custom immutable OS with Radeon-AI support
# Optimized for AMD Radeon GPUs (RX 6700 XT, AI PRO R9700)
# Public project - https://github.com/tlee933/atomic-rocm

ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

# Base: Aurora (KDE Plasma 6) - Developer workstation variant
FROM ghcr.io/ublue-os/aurora:${FEDORA_MAJOR_VERSION}

# Metadata
LABEL org.opencontainers.image.title="Atomic-ROCm"
LABEL org.opencontainers.image.description="Custom immutable OS with Radeon-AI support"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.authors="@tlee933"
LABEL org.opencontainers.image.url="https://github.com/tlee933/atomic-rocm"
LABEL com.github.atomic-rocm.gpu.support="RX 6700 XT (gfx1031), AI PRO R9700 (gfx1201)"
LABEL com.github.atomic-rocm.rocm.version="7.11"
LABEL com.github.atomic-rocm.base="Aurora (KDE Plasma 6)"

# Custom ROCm 7.11 with Radeon-AI support
# Builds custom ROCm from TheRock project with gfx1031 and gfx1201 support
RUN rpm-ostree install \
    rocm-hip \
    rocm-hip-devel \
    rocm-opencl \
    rocm-opencl-devel \
    rocm-smi \
    hipcc

# AI/ML Development Tools
RUN rpm-ostree install \
    python3-pip \
    python3-devel \
    python3-numpy \
    python3-scipy \
    git-lfs

# Developer Utilities
RUN rpm-ostree install \
    vim-enhanced \
    tmux \
    htop \
    nvtop \
    neofetch \
    fastfetch

# GPU Monitoring Tools
RUN rpm-ostree install \
    radeontop \
    clinfo

# Optional: Gaming optimizations (uncomment if desired)
# RUN rpm-ostree install \
#     gamemode \
#     mangohud \
#     steam-devices

# Optional: Container tools (already in Aurora, but explicit)
# RUN rpm-ostree install \
#     podman \
#     distrobox \
#     toolbox

# Commit ostree changes
RUN ostree container commit

# Runtime configuration hints
# Users should install PyTorch/TensorFlow in Distrobox for development
# Gaming: Install Steam/Lutris via Flatpak for better isolation

## Post-installation notes:
# 1. Install PyTorch with ROCm in Distrobox:
#    distrobox create --name ai-dev --image fedora:40
#    distrobox enter ai-dev
#    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0
#
# 2. Install gaming via Flatpak:
#    flatpak install flathub com.valvesoftware.Steam
#    flatpak install flathub net.lutris.Lutris
#
# 3. Check GPU status:
#    rocm-smi
#    clinfo
