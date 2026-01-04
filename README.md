# Atomic-ROCm

**Custom immutable OS with Radeon-AI support**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Based on Aurora](https://img.shields.io/badge/Base-Aurora-blue)](https://github.com/ublue-os/aurora)
[![ROCm 7.11](https://img.shields.io/badge/ROCm-7.11-red)](https://rocm.docs.amd.com/)

Atomic-ROCm is an immutable Fedora desktop optimized for AMD Radeon AI workloads. Built on [Universal Blue](https://universal-blue.org/) Aurora with custom ROCm 7.11 and Radeon-AI support.

**Public project - fork and customize for your needs.**

---

## Features

### 🔵 Immutable Infrastructure
- Read-only root filesystem
- Atomic updates with rollback
- OCI container-based OS delivery
- GitOps workflow with GitHub Actions

### 🎮 Radeon-AI Gaming
- Custom ROCm 7.11 build
- Optimized for RX 6700 XT (gfx1031)
- Optimized for AI PRO R9700 (gfx1201)
- Gaming-ready with Steam/Proton support

### 🧠 AI/ML Development
- ROCm HIP/OpenCL support
- PyTorch/TensorFlow compatible
- GPU compute for AI workloads
- Development tools pre-installed

### 🖥️ KDE Plasma 6
- Modern desktop environment
- Wayland support
- Professional workflow tools
- Beautiful and performant

---

## Supported Hardware

**Tested GPUs:**
- ✅ AMD Radeon RX 6700 XT (gfx1031, 12GB VRAM)
- ✅ AMD Radeon AI PRO R9700 (gfx1201, 32GB VRAM)

**Compatible GPUs (untested but should work):**
- RDNA2 (gfx103X): RX 6600/6700/6800/6900 series
- RDNA4 (gfx120X): RX 9070 series (future)

---

## Installation

### Option 1: Rebase from Existing Atomic Desktop

If you're already on Fedora Silverblue, Kinoite, or Aurora:

```bash
# Rebase to Atomic-ROCm
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest

# Reboot
systemctl reboot
```

After reboot, you're running Atomic-ROCm!

### Option 2: Install from ISO (Future)

**Coming soon:** Bootable ISOs generated with `bootc install to-disk`

---

## Quick Start

### Check GPU Status

```bash
# ROCm SMI
rocm-smi

# OpenCL info
clinfo

# GPU monitoring
radeontop
```

### AI/ML Development

**Use Distrobox for isolation:**

```bash
# Create AI development container
distrobox create --name ai-dev --image fedora:40
distrobox enter ai-dev

# Inside container: Install PyTorch with ROCm
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.0

# Test GPU
python -c "import torch; print(torch.cuda.is_available())"
```

### Gaming

**Install via Flatpak (recommended):**

```bash
# Steam
flatpak install flathub com.valvesoftware.Steam

# Lutris
flatpak install flathub net.lutris.Lutris

# Heroic Games Launcher
flatpak install flathub com.heroicgameslauncher.hgl
```

### System Updates

**Automatic updates:**
- rpm-ostree checks for updates daily
- Updates applied on next reboot
- Previous deployment available for rollback

**Manual update:**
```bash
# Check for updates
rpm-ostree upgrade --check

# Apply update
rpm-ostree upgrade

# Reboot
systemctl reboot
```

**Rollback:**
```bash
# Rollback to previous deployment
rpm-ostree rollback

# Reboot
systemctl reboot
```

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Applications (Mutable)                         │
│  - Flatpak apps (Steam, etc.)                   │
│  - Distrobox containers (AI/ML dev)             │
│  - User home directory                          │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Layered Packages (Optional)                    │
│  - rpm-ostree install <package>                 │
│  - Persists across updates                      │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Base Image: Atomic-ROCm (IMMUTABLE)            │
│  - Aurora (KDE Plasma 6)                        │
│  - ROCm 7.11 with Radeon-AI support             │
│  - Development tools                            │
│  - OCI container image                          │
└─────────────────────────────────────────────────┘
```

---

## Build Your Own

### Fork and Customize

1. **Fork this repository**
2. **Edit Containerfile** - Add your packages
3. **Push to GitHub** - Actions build automatically
4. **Deploy** - Rebase to your custom image

### Local Build

```bash
# Clone repository
git clone https://github.com/tlee933/atomic-rocm.git
cd atomic-rocm

# Build locally
podman build -t atomic-rocm:test .

# Test in container
podman run --rm -it atomic-rocm:test bash
```

### GitHub Actions

Automatic builds on:
- Every push to `main`
- Daily schedule (keep up to date with upstream)
- Manual trigger

Images pushed to: `ghcr.io/tlee933/atomic-rocm`

---

## FAQ

### Why Atomic-ROCm?

**Problem:** AMD Radeon GPUs lack official ROCm support for consumer cards (RX 6700 XT) and newer architectures (gfx1201).

**Solution:** Custom ROCm build with gfx1031/gfx1201 support + immutable OS for stability.

### Is this official?

**No.** Atomic-ROCm is not affiliated with:
- AMD/ROCm team
- Universal Blue project
- Fedora/Red Hat

Built on excellent upstream projects.

### What's the difference from stock Aurora?

| Feature | Aurora | Atomic-ROCm |
|---------|--------|-------------|
| Base | Universal Blue Aurora | Same |
| ROCm | Standard Fedora packages | Custom 7.11 build |
| GPU Support | Standard AMD GPUs | gfx1031, gfx1201 optimized |
| AI/ML | Via containers | Pre-configured tools |
| Gaming | Via Flatpak | ROCm gaming optimization |

### Can I contribute?

**Yes!** Contributions welcome.

**Ways to contribute:**
- Test on your AMD GPU and report results
- Submit improvements to Containerfile
- Add documentation
- Share use cases
- Report issues

Open an issue or PR!

### Is it stable?

**Current status:** Experimental, use at your own risk.

**Stability notes:**
- ✅ Base Aurora is very stable (Universal Blue)
- ✅ Immutable OS provides rollback safety
- ⚠️ Custom ROCm build is experimental
- ⚠️ gfx1031/gfx1201 support is unofficial

**Recommendation:** Test in VM first, keep backup deployment.

### How do updates work?

**Base image updates:**
- GitHub Actions rebuilds daily
- Pulls latest Aurora upstream
- Keeps custom ROCm packages
- You pull via `rpm-ostree upgrade`

**ROCm updates:**
- Manual Containerfile edits
- Push triggers rebuild
- New image available within hours

---

## Troubleshooting

### GPU not detected

```bash
# Check ROCm installation
rocm-smi

# Check OpenCL
clinfo

# Check kernel modules
lsmod | grep amdgpu
```

### PyTorch not using GPU

```bash
# Inside Distrobox, check PyTorch
python -c "import torch; print(torch.cuda.is_available())"

# Should return True
# If False, reinstall with ROCm:
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/rocm6.0
```

### Steam games not launching

```bash
# Ensure Flatpak Steam is installed
flatpak list | grep Steam

# Update Steam
flatpak update

# Check Proton compatibility layer
# Steam Settings → Compatibility → Enable Proton
```

### System won't boot after update

```bash
# At GRUB menu, select previous deployment
# Or from running system:
rpm-ostree rollback
systemctl reboot
```

---

## Roadmap

**Current (v1.0):**
- ✅ Custom ROCm 7.11 build
- ✅ gfx1031, gfx1201 support
- ✅ Aurora base (KDE Plasma 6)
- ✅ GitHub Actions automation

**Future:**
- [ ] Bootable ISOs via bootc
- [ ] Gaming variant (Bazzite-based)
- [ ] Pre-built PyTorch container image
- [ ] Performance benchmarks
- [ ] Community testing program
- [ ] UEFI secure boot signing

---

## Credits

**Built on:**
- [Universal Blue](https://universal-blue.org/) - Cloud-native atomic desktop
- [Aurora](https://github.com/ublue-os/aurora) - KDE Plasma 6 variant
- [ROCm](https://rocm.docs.amd.com/) - AMD GPU compute platform
- [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) - Immutable Fedora

**Inspired by:**
- [TheRock project](https://github.com/tlee933/TheRock) - Custom ROCm build
- Community ROCm builds for unsupported GPUs
- Immutable infrastructure movement

**Special thanks:**
- Universal Blue community
- AMD ROCm team
- Fedora Atomic Desktop team

---

## License

MIT License - see [LICENSE](LICENSE) file

**Disclaimer:** This is a personal project not affiliated with AMD, Universal Blue, or Fedora. Use at your own risk.

---

## Contact

- **GitHub:** [@tlee933](https://github.com/tlee933)
- **Issues:** [GitHub Issues](https://github.com/tlee933/atomic-rocm/issues)
- **Discussions:** [GitHub Discussions](https://github.com/tlee933/atomic-rocm/discussions)

---

**Atomic-ROCm: Where immutable infrastructure meets Radeon-AI computing** 🚀
