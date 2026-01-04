# Atomic-ROCm Quick Start Guide

**Ready to launch your custom immutable OS project!**

---

## What You Have

This starter package includes everything needed to build and share **Atomic-ROCm**:

```
atomic-rocm/
├── Containerfile              # Image definition
├── README.md                  # Project documentation
├── LICENSE                    # MIT license
├── CONTRIBUTING.md            # Contribution guide
├── .gitignore                 # Git ignore patterns
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions automation
└── QUICK_START.md            # This file
```

---

## Next Steps

### 1. Create GitHub Repository

```bash
# Copy files to your project directory
cp -r /tmp/atomic-rocm ~/atomic-rocm
cd ~/atomic-rocm

# Initialize git
git init
git add .
git commit -m "Initial Atomic-ROCm setup"

# Create GitHub repo (using gh CLI)
gh repo create atomic-rocm --public \
  --description "Custom immutable OS with Radeon-AI support" \
  --push --source .

# Or create manually on GitHub.com and push:
git remote add origin https://github.com/tlee933/atomic-rocm.git
git branch -M main
git push -u origin main
```

### 2. Enable GitHub Actions

**GitHub Actions will automatically:**
- Build your image on every push
- Rebuild daily to stay current
- Push to `ghcr.io/tlee933/atomic-rocm`

**To enable:**
1. Go to repository Settings → Actions → General
2. Allow "Read and write permissions" for GITHUB_TOKEN
3. Push Containerfile change to trigger first build

### 3. Customize Your Image

**Edit `Containerfile` to add:**

```dockerfile
# Your custom ROCm build from TheRock
COPY --from=your-rocm-build /opt/rocm /opt/rocm

# Or install additional packages
RUN rpm-ostree install \
    package1 \
    package2

# Add custom scripts
COPY scripts/ /usr/local/bin/
```

**Common customizations:**
- Add gaming packages (gamemode, mangohud)
- Include AI frameworks (pre-install PyTorch)
- Custom shell configuration
- Development tools
- System utilities

### 4. Test Locally

```bash
# Build image
podman build -t atomic-rocm:test .

# Test in container
podman run --rm -it atomic-rocm:test bash

# Inside container, verify:
rocm-smi
clinfo
rpm -qa | grep rocm
```

### 5. Deploy to Your Machine

**Once GitHub Actions builds your image:**

```bash
# On target machine (Fedora Atomic/Silverblue/Kinoite)
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest

# Reboot
systemctl reboot
```

**After reboot, verify:**
```bash
# Check deployment
rpm-ostree status

# Check GPU
rocm-smi

# Check packages
rpm -qa | grep rocm
```

---

## Customization Examples

### Add Your Custom ROCm Build

```dockerfile
# In Containerfile, replace standard ROCm with TheRock build
# Option 1: Copy from host (during build)
# COPY /path/to/TheRock/install /opt/rocm

# Option 2: Build multi-stage
# FROM your-rocm-builder AS rocm-build
# ... build ROCm ...
# FROM ghcr.io/ublue-os/aurora:40
# COPY --from=rocm-build /opt/rocm /opt/rocm
```

### Add Gaming Optimizations

```dockerfile
# Uncomment in Containerfile:
RUN rpm-ostree install \
    gamemode \
    mangohud \
    steam-devices

# Enable performance governor
RUN echo 'governor=performance' > /etc/gamemode.ini
```

### Pre-install PyTorch

```dockerfile
# Create AI/ML layer
RUN rpm-ostree install \
    python3-torch \
    python3-torchvision \
    python3-torchaudio

# Or provide container image
# (Better: Use Distrobox as documented)
```

---

## Workflow Tips

### Daily Development

```bash
# Edit Containerfile
vim Containerfile

# Test locally
podman build -t atomic-rocm:test .

# Commit and push (triggers GitHub build)
git add Containerfile
git commit -m "Add package XYZ"
git push
```

### Version Tags

```bash
# GitHub Actions creates these tags automatically:
# - latest (always newest)
# - 40 (Fedora version)
# - 20250103 (date-based)
# - main-abc1234 (git commit)

# Pin to specific version:
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:20250103
```

### Share with Community

1. **Test thoroughly** on your hardware
2. **Document** GPU compatibility in README
3. **Tag releases** for stable versions
4. **Enable Discussions** on GitHub repo
5. **Share** on Reddit, forums, social media

---

## Branding Ideas

### Repository Description

> Atomic-ROCm: Custom immutable Fedora desktop with Radeon-AI support. Optimized for AMD RX 6700 XT and AI PRO R9700 GPUs. Built on Universal Blue Aurora with ROCm 7.11.

### Social Media

> Just released Atomic-ROCm! 🚀
>
> Custom immutable OS with Radeon-AI support for AMD GPUs. Built on @UniversalBlue Aurora with ROCm 7.11.
>
> ✅ RX 6700 XT (gfx1031)
> ✅ AI PRO R9700 (gfx1201)
> ✅ KDE Plasma 6
> ✅ Gaming + AI/ML ready
>
> Check it out: github.com/tlee933/atomic-rocm

### Repository Topics

Add these tags on GitHub:
- `rocm`
- `amd-gpu`
- `immutable-os`
- `universal-blue`
- `fedora-atomic`
- `kde-plasma`
- `ai-ml`
- `gaming`
- `radeon`

---

## Maintenance

### Weekly Tasks
- Review upstream Aurora changes
- Check GitHub Actions builds
- Respond to issues/PRs

### Monthly Tasks
- Update ROCm version (if needed)
- Review Containerfile packages
- Update documentation

### When to Release

Create release when:
- Major feature added
- Significant stability improvement
- ROCm version update
- Fedora version update

```bash
# Create release
git tag -a v1.0.0 -m "Release v1.0.0 - Initial stable release"
git push origin v1.0.0

# Or use GitHub Releases UI
```

---

## Getting Help

**Need assistance?**
- Check [UBLUE_GUIDE.md](../rai/UBLUE_GUIDE.md) in rai repo
- Universal Blue docs: https://universal-blue.org/
- ROCm docs: https://rocm.docs.amd.com/
- Ask in GitHub Discussions

**Found a bug in rai?**
- Report at: https://github.com/tlee933/rai/issues

---

## Success Checklist

- [ ] Repository created on GitHub
- [ ] GitHub Actions enabled
- [ ] First build completed successfully
- [ ] Image available at ghcr.io/tlee933/atomic-rocm
- [ ] README.md customized with your info
- [ ] Tested locally in container
- [ ] (Optional) Tested on actual hardware
- [ ] (Optional) Shared with community

---

**You're ready to build and share Atomic-ROCm!** 🎉

Questions? Open an issue or discussion on GitHub.
