# Atomic-ROCm: Cloud-Native OCI Strategy

**Philosophy:** Minimal immutable base + user-space tools = Maximum flexibility, minimal bloat

---

## Cloud-Native Principles

### The OCI Way

```
Traditional Desktop:           Cloud-Native Atomic:
┌─────────────────────┐       ┌─────────────────────┐
│  Everything in /    │       │  Minimal Base Image │
│  (Mutable mess)     │       │  (Immutable, tiny)  │
└─────────────────────┘       └─────────────────────┘
                                        ↓
                              ┌─────────────────────┐
                              │  Homebrew Layer     │
                              │  (User-space tools) │
                              └─────────────────────┘
                                        ↓
                              ┌─────────────────────┐
                              │  Flatpak Layer      │
                              │  (GUI apps)         │
                              └─────────────────────┘
                                        ↓
                              ┌─────────────────────┐
                              │  Distrobox Layer    │
                              │  (Dev environments) │
                              └─────────────────────┘
```

**Key insight:** Treat the OS like a container - minimal, declarative, reproducible.

---

## Minimal Base Image Strategy

### What Goes in rpm-ostree (Base Image)

**ONLY essentials that MUST be in the base:**

```dockerfile
FROM ghcr.io/ublue-os/bazzite:stable

# ============================================
# CRITICAL SYSTEM PACKAGES ONLY
# ============================================

# GPU drivers and compute stack
RUN rpm-ostree install \
    /opt/rocm/lib/*.rpm \
    /opt/rocm/bin/*.rpm

# Theming (small, affects all users)
RUN rpm-ostree install \
    papirus-icon-theme \
    klassy \
    kwin-effects-extra

# That's it! Keep base minimal!
```

**Total base additions:** ~500 MB max (ROCm + theming)

---

## What Goes in Homebrew (User-Space)

**Everything else!** Homebrew is the new default for CLI tools.

### Development Tools

```bash
# Version control
brew install git gh lazygit

# Text editors
brew install neovim helix

# Build tools
brew install cmake ninja ccache

# Modern CLI replacements
brew install ripgrep fd bat exa zoxide fzf starship
```

### Programming Languages

```bash
# Python (latest version, not Fedora 42's old one!)
brew install python@3.14

# Node.js
brew install node

# Go
brew install go

# Rust
brew install rust
```

### System Utilities

```bash
# Monitoring
brew install htop btop nvtop

# Disk usage
brew install ncdu duf dust

# Network
brew install speedtest-cli bandwhich
```

### AI/ML Tools

```bash
# Jupyter
brew install jupyterlab

# Hugging Face
brew install huggingface-cli

# Python ML packages (via pip in Homebrew Python)
/home/linuxbrew/.linuxbrew/bin/pip3 install torch torchvision transformers
```

---

## Containerfile: Cloud-Native Best Practices

### Minimal, Declarative, OCI-Compliant

```dockerfile
# ============================================
# Atomic-ROCm: Cloud-Native Immutable Desktop
# ============================================

# Base: Bazzite (includes Homebrew, Flatpak, Distrobox)
FROM ghcr.io/ublue-os/bazzite:stable

# OCI labels (best practice for container images)
LABEL org.opencontainers.image.title="Atomic-ROCm"
LABEL org.opencontainers.image.description="AMD ROCm + KDE Plasma 6 Immutable Desktop"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="hashcat"
LABEL org.opencontainers.image.base.name="ghcr.io/ublue-os/bazzite:stable"
LABEL com.github.atomic-rocm.rocm.version="7.11"
LABEL com.github.atomic-rocm.gpu.target="gfx1201"

# ============================================
# LAYER 1: ROCm Compute Stack (CRITICAL)
# ============================================

# Copy custom ROCm build from TheRock
COPY --from=builder /opt/rocm /opt/rocm

# Or install from custom repo
# RUN rpm-ostree install rocm-hip rocm-opencl

# Set up ROCm environment
RUN echo 'export ROCM_PATH=/opt/rocm' >> /etc/profile.d/rocm.sh && \
    echo 'export PATH=$ROCM_PATH/bin:$PATH' >> /etc/profile.d/rocm.sh && \
    echo 'export LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$LD_LIBRARY_PATH' >> /etc/profile.d/rocm.sh

# Configure ldconfig for ROCm libraries
RUN echo '/opt/rocm/lib' >> /etc/ld.so.conf.d/rocm.conf && \
    echo '/opt/rocm/lib64' >> /etc/ld.so.conf.d/rocm.conf && \
    ldconfig

# ============================================
# LAYER 2: Theming (SMALL, affects all users)
# ============================================

# Install theme packages (minimal set)
RUN rpm-ostree install \
    papirus-icon-theme \
    klassy \
    kwin-effects-extra

# Copy custom assets (wallpapers, color schemes)
COPY wallpapers/rocm-dark-blue.jpg /usr/share/backgrounds/atomic-rocm/
COPY wallpapers/rocm-purple-gradient.jpg /usr/share/backgrounds/atomic-rocm/
COPY wallpapers/plasma-colorscheme/AtomicROCm.colors /usr/share/color-schemes/
COPY konsole/AtomicROCm.colorscheme /usr/share/konsole/

# Configure default theme (Plasma 6)
RUN mkdir -p /etc/skel/.config && \
    kwriteconfig6 --file /etc/skel/.config/plasmarc \
        --group Wallpaper --key Image "/usr/share/backgrounds/atomic-rocm/rocm-dark-blue.jpg" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals \
        --group General --key ColorScheme "AtomicROCm" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals \
        --group Icons --key Theme "Papirus-Dark"

# Enable compositor effects (glassy windows)
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key Enabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key blurEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Effect-blur --key BlurStrength 10 && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group org.kde.kdecoration2 --key library org.kde.klassy && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key TitleBarOpacity 70 && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key BlurBehindTitle true

# Transparent panel
RUN kwriteconfig6 --file /etc/skel/.config/plasmashellrc \
    --group PlasmaViews --group Panel --group Defaults --key panelOpacity 80

# ============================================
# LAYER 3: ujust Recipes (User automation)
# ============================================

# Copy custom ujust recipes
COPY just/install-brew-essentials.just /usr/share/ublue-os/just/
COPY just/install-ml-tools.just /usr/share/ublue-os/just/
COPY just/setup-rocm-dev.just /usr/share/ublue-os/just/

# ============================================
# CLEANUP & FINALIZE
# ============================================

# Clean up package manager cache
RUN rpm-ostree cleanup -m && \
    ostree container commit

# ============================================
# END OF IMAGE
# ============================================
# Final image size target: ~8-10 GB
# (Bazzite base ~6 GB + ROCm ~2 GB + theming ~500 MB)
```

---

## ujust Recipes for User Setup

**Instead of bloating the base image, provide recipes users run once:**

### `/usr/share/ublue-os/just/install-brew-essentials.just`

```justfile
# Install essential CLI tools via Homebrew
install-brew-essentials:
    #!/usr/bin/env bash
    echo "Installing essential Homebrew packages..."
    brew install \
        git gh lazygit \
        neovim helix \
        ripgrep fd bat exa zoxide fzf starship \
        htop btop nvtop \
        ncdu duf dust \
        tmux \
        cmake ninja ccache
    echo "✓ Homebrew essentials installed!"
```

### `/usr/share/ublue-os/just/install-ml-tools.just`

```justfile
# Install AI/ML development tools
install-ml-tools:
    #!/usr/bin/env bash
    echo "Installing AI/ML tools via Homebrew..."
    brew install python@3.14 jupyterlab huggingface-cli

    echo "Installing PyTorch with ROCm support..."
    /home/linuxbrew/.linuxbrew/bin/pip3 install \
        torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/rocm6.2

    echo "Installing ML libraries..."
    /home/linuxbrew/.linuxbrew/bin/pip3 install \
        transformers datasets accelerate \
        jupyter ipython pandas numpy scipy matplotlib

    echo "✓ ML tools installed!"
```

### `/usr/share/ublue-os/just/setup-rocm-dev.just`

```justfile
# Set up ROCm development environment
setup-rocm-dev:
    #!/usr/bin/env bash
    echo "Setting up ROCm development environment..."

    # Install build tools via Homebrew
    brew install cmake ninja ccache git

    # Create dev workspace
    mkdir -p ~/ROCm-Projects

    # Verify ROCm installation
    /opt/rocm/bin/rocminfo
    /opt/rocm/bin/rocm-smi

    echo "✓ ROCm dev environment ready!"
    echo "Workspace: ~/ROCm-Projects"
```

---

## User First-Boot Experience

**After installing Atomic-ROCm:**

```bash
# 1. System boots into glassy, themed KDE Plasma 6
#    (wallpapers, colors, transparency already configured)

# 2. User opens terminal and runs:
ujust install-brew-essentials    # Installs CLI tools (5 min)
ujust install-ml-tools            # Installs AI/ML stack (15 min)
ujust setup-rocm-dev              # Sets up ROCm development

# 3. Install GUI apps via Flatpak (as needed)
flatpak install flathub com.visualstudio.code
flatpak install flathub org.mozilla.firefox

# 4. Done! Full development environment without touching base image
```

---

## Benefits of This Approach

### 1. Minimal Base Image
- **Small size:** ~8-10 GB total (vs 20+ GB bloated images)
- **Fast updates:** Less to download when image updates
- **Quick rollback:** Smaller diff between deployments

### 2. User Flexibility
- **No sudo needed:** Homebrew installs to user home
- **No reboots:** Install tools anytime with `brew install`
- **Easy experimentation:** Try tools without committing to image

### 3. Reproducible Builds
- **Declarative Containerfile:** Every build is identical
- **Version pinning:** Lock ROCm, themes to specific versions
- **OCI compliant:** Works with any OCI registry

### 4. Cloud-Native Philosophy
- **Infrastructure as Code:** Containerfile is source of truth
- **Immutable infrastructure:** Base never changes, only layers
- **Cattle, not pets:** Reinstall anytime from image

---

## Image Size Comparison

```
Traditional Fedora Desktop:
├─ Base system: 4 GB
├─ KDE Desktop: 2 GB
├─ Development tools: 3 GB
├─ Applications: 5 GB
├─ User data: 10+ GB
└─ TOTAL: 24+ GB (and growing!)

Atomic-ROCm (Cloud-Native):
├─ Base image: 6 GB (Bazzite)
├─ ROCm layer: 2 GB
├─ Theming layer: 500 MB
├─ TOTAL BASE: 8.5 GB ← Small, fast, reproducible!
│
├─ Homebrew: 2-5 GB (user-space, as needed)
├─ Flatpak: 2-10 GB (per-app, sandboxed)
└─ User data: 10+ GB (separate partition)
```

---

## OCI Image Metadata

**Best practices for cloud-native images:**

```dockerfile
# Standard OCI labels
LABEL org.opencontainers.image.created="2026-01-04T00:00:00Z"
LABEL org.opencontainers.image.revision="a95249c3"
LABEL org.opencontainers.image.source="https://github.com/hashcat/atomic-rocm"
LABEL org.opencontainers.image.url="https://github.com/hashcat/atomic-rocm"
LABEL org.opencontainers.image.documentation="https://github.com/hashcat/atomic-rocm/blob/main/README.md"

# Custom labels for Atomic-ROCm
LABEL com.github.atomic-rocm.rocm.version="7.11"
LABEL com.github.atomic-rocm.rocm.commit="a95249c3"
LABEL com.github.atomic-rocm.gpu.targets="gfx1201"
LABEL com.github.atomic-rocm.base.image="ghcr.io/ublue-os/bazzite:stable"
LABEL com.github.atomic-rocm.plasma.version="6"
LABEL com.github.atomic-rocm.homebrew.included="true"
```

**Query image metadata:**

```bash
# Check ROCm version in image
podman inspect ghcr.io/hashcat/atomic-rocm:latest | jq '.[0].Config.Labels["com.github.atomic-rocm.rocm.version"]'

# Check GPU targets
rpm-ostree status --json | jq '.deployments[0].base-commit-meta'
```

---

## GitHub Actions: Cloud-Native CI/CD

**Build pipeline optimized for OCI:**

```yaml
name: Build Atomic-ROCm OCI Image

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'  # Weekly rebuilds

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Build with Podman (OCI-native)
      - name: Build OCI image
        run: |
          podman build \
            --tag ghcr.io/${{ github.repository }}:latest \
            --label org.opencontainers.image.created=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
            --label org.opencontainers.image.revision=${{ github.sha }} \
            .

      # Push to GitHub Container Registry
      - name: Push to GHCR
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" | podman login ghcr.io -u ${{ github.actor }} --password-stdin
          podman push ghcr.io/${{ github.repository }}:latest

      # Sign with cosign (supply chain security)
      - name: Sign image
        run: |
          cosign sign --key env://COSIGN_KEY ghcr.io/${{ github.repository }}:latest
        env:
          COSIGN_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
```

---

## Summary: The Cloud-Native Way

### Old Approach (Bloated)
```
rpm-ostree install everything
↓
20 GB base image
↓
Slow updates, slow rollbacks
↓
Reboot for every package
```

### Cloud-Native Approach (Atomic-ROCm)
```
Minimal base (8 GB)
↓
Homebrew for CLI tools (user-space)
↓
Flatpak for GUI apps (sandboxed)
↓
Fast, flexible, reproducible
```

---

## Next Steps

1. ✅ Create minimal Containerfile (ROCm + theming only)
2. ✅ Create ujust recipes for Homebrew setup
3. ⏳ Build and test image
4. ⏳ Push to GHCR
5. ⏳ Install on nvme1n1
6. ⏳ Run ujust recipes on first boot

**Total base image target:** 8-10 GB (vs 20+ GB traditional)
**User setup time:** 20 minutes (automated via ujust)
**Result:** Fast, clean, cloud-native immutable desktop! 🚀

---

**Created:** 2026-01-04
**Philosophy:** Minimal base + user-space tools = Maximum efficiency
**Status:** Ready to implement
