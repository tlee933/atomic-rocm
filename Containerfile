# Atomic-ROCm: Gaming + AI workstation with custom ROCm 7.11
# Exclusively for AMD Radeon AI PRO R9700 (gfx1201)
# Mix of Bazzite (gaming) + Aurora (KDE) with TheRock custom ROCm
# Public project - https://github.com/tlee933/atomic-rocm

ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-42}"

# Stage 1: Import TheRock ROCm build
FROM scratch AS rocm-source
COPY TheRock/install /rocm

# Stage 2: Base image
FROM ghcr.io/ublue-os/bazzite:${FEDORA_MAJOR_VERSION}

# Metadata
LABEL org.opencontainers.image.title="Atomic-ROCm"
LABEL org.opencontainers.image.description="Gaming + AI workstation with custom ROCm for R9700"
LABEL org.opencontainers.image.version="1.0.0-gfx1201"
LABEL org.opencontainers.image.authors="@tlee933"
LABEL org.opencontainers.image.url="https://github.com/tlee933/atomic-rocm"
LABEL com.github.atomic-rocm.gpu.support="AMD Radeon AI PRO R9700 (gfx1201)"
LABEL com.github.atomic-rocm.gpu.target="gfx1201"
LABEL com.github.atomic-rocm.rocm.version="7.11-custom"
LABEL com.github.atomic-rocm.rocm.source="TheRock"
LABEL com.github.atomic-rocm.base="Bazzite (gaming) + KDE"

# Remove any existing ROCm packages to avoid conflicts
RUN rpm-ostree override remove \
    rocm-hip \
    rocm-opencl \
    rocm-smi \
    || true

# Install build dependencies for custom ROCm integration
RUN rpm-ostree install \
    pciutils \
    mesa-vulkan-drivers \
    vulkan-loader

# Gaming essentials (may already be in Bazzite, but ensure they're present)
RUN rpm-ostree install \
    gamemode \
    mangohud \
    steam-devices \
    vkBasalt \
    goverlay

# AI/ML Development Tools
RUN rpm-ostree install \
    python3-pip \
    python3-devel \
    python3-numpy \
    python3-scipy \
    git-lfs

# Developer Utilities (Aurora-style)
RUN rpm-ostree install \
    vim-enhanced \
    tmux \
    htop \
    fastfetch \
    zsh

# GPU Monitoring Tools
RUN rpm-ostree install \
    radeontop \
    clinfo

# Container development tools
RUN rpm-ostree install \
    podman \
    distrobox \
    toolbox

# Copy custom ROCm 7.11 from TheRock build (gfx1201 support)
COPY --from=rocm-source /rocm /opt/rocm

# Set ownership and permissions for ROCm
RUN chown -R root:root /opt/rocm && \
    chmod -R a+rX /opt/rocm

# Configure environment for custom ROCm stack
# ROCm is for AI/ML compute only, NOT for gaming graphics
RUN mkdir -p /etc/profile.d && \
    cat > /etc/profile.d/atomic-rocm.sh << 'EOF'
# Atomic-ROCm environment configuration
# ROCm 7.11 custom stack for AI/ML compute (gfx1201)

# ROCm paths (for AI/ML workloads in Distrobox)
export ROCM_PATH=/opt/rocm
export ROCM_HOME=/opt/rocm
export HIP_PATH=/opt/rocm
export HIP_PLATFORM=amd

# Binary paths
export PATH=/opt/rocm/bin:/opt/rocm/llvm/bin:$PATH

# GPU targeting for R9700 (gfx1201) - for compute workloads
export HSA_OVERRIDE_GFX_VERSION=12.0.1

# Gaming uses Vulkan/Mesa (RADV), not ROCm
# These optimizations are for graphics rendering
export RADV_PERFTEST=gpl,nggc
export AMD_VULKAN_ICD=RADV
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

# Disable NVIDIA workarounds
export PROTON_ENABLE_NVAPI=0
export PROTON_HIDE_NVIDIA_GPU=1
EOF

# Configure dynamic linker for ROCm (AI/ML workloads only)
# DO NOT put this first - gaming needs system Mesa libs first
RUN cat > /etc/ld.so.conf.d/99-atomic-rocm.conf << 'EOF'
/opt/rocm/lib
/opt/rocm/lib64
EOF

# Configure GameMode for optimal R9700 performance
RUN mkdir -p /etc/gamemode && \
    cat > /etc/gamemode/gamemode.ini << 'EOF'
[general]
; GameMode configuration for AMD R9700
renice=10
ioprio=0
inhibit_screensaver=1

[gpu]
; Apply GPU optimizations
apply_gpu_optimisations=accept-responsibility
gpu_device=0

[custom]
; Custom start commands
start=echo performance | tee /sys/class/drm/card*/device/power_dpm_force_performance_level

; Custom end commands
end=echo auto | tee /sys/class/drm/card*/device/power_dpm_force_performance_level
EOF

# Configure MangoHud for R9700 monitoring
RUN mkdir -p /etc/mangohud && \
    cat > /etc/mangohud/MangoHud.conf << 'EOF'
# MangoHud configuration for AMD R9700

# GPU stats
gpu_stats
gpu_temp
gpu_load_change
gpu_load_value=60,90
gpu_load_color=39F900,FDFD09,B22222
gpu_text=R9700

# VRAM stats
vram
vram_color=AD64C1

# Performance
fps
frametime
frame_timing

# System
cpu_stats
cpu_temp
ram

# Layout
position=top-left
background_alpha=0.4
font_size=24
EOF

# Set gfx1201 as the only supported architecture
# Create a marker file that tools can check
RUN echo "gfx1201" > /etc/atomic-rocm-target && \
    echo "AMD Radeon AI PRO R9700" > /etc/atomic-rocm-gpu

# Commit ostree changes
RUN ostree container commit

# Runtime information
RUN cat > /etc/motd << 'EOF'

   ╔═══════════════════════════════════════════════════════════╗
   ║                     Atomic-ROCm                           ║
   ║            Gaming + AI for AMD R9700 (gfx1201)            ║
   ║                                                           ║
   ║  GPU:     AMD Radeon AI PRO R9700 (32GB VRAM)            ║
   ║  Gaming:  Vulkan/Mesa (RADV) + Steam + GameMode          ║
   ║  AI/ML:   ROCm 7.11 (TheRock) for GPU compute            ║
   ║                                                           ║
   ╚═══════════════════════════════════════════════════════════╝

  Graphics stack:
    Gaming:  Mesa/RADV → Vulkan/OpenGL → Steam/Proton
    AI/ML:   ROCm 7.11 → HIP/OpenCL → PyTorch (in Distrobox)

  Quick commands:
    steam                - Launch Steam (uses Vulkan/Mesa)
    rocm-smi             - Check GPU status (for AI/ML)
    clinfo               - Verify OpenCL (for AI/ML)
    gamemode-status      - Check GameMode

  Environment configured for gfx1201:
    ROCM_PATH=/opt/rocm (for AI/ML compute)
    HSA_OVERRIDE_GFX_VERSION=12.0.1 (for compute workloads)

EOF

## Post-build instructions:
#
# Build with custom ROCm from TheRock:
#   cd ~/projects/atomic-rocm
#   podman build \
#     --volume ~/TheRock/install:/rocm-build:ro \
#     --build-arg FEDORA_MAJOR_VERSION=40 \
#     -t atomic-rocm:gfx1201 .
#
# Then add COPY instruction above to actually copy ROCm files
#
# Push to registry:
#   podman tag atomic-rocm:gfx1201 ghcr.io/tlee933/atomic-rocm:latest
#   podman push ghcr.io/tlee933/atomic-rocm:latest
