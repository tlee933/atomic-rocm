# Deploy Atomic-ROCm to nvme1n1 🚀

## Current Status

✅ **Image Ready**: ghcr.io/tlee933/atomic-rocm:latest  
✅ **Base**: Aurora-DX (KDE Plasma 6 + Dev Tools)  
✅ **Disk Ready**: nvme1n1 partitioned and formatted  
✅ **Theming**: Glassy blue/cyan/purple, all configured  
✅ **ROCm**: 7.11 custom build for R9700 (gfx1201)  

---

## Deployment Steps (30 minutes)

### Step 1: Get Aurora ISO

**Option A - Download directly:**
```bash
cd ~/atomic-rocm-install
wget https://download.projectbluefin.io/aurora-gts-stable.iso
# OR
curl -L -O https://download.projectbluefin.io/aurora-gts-stable.iso
```

**Option B - Use Fedora Media Writer:**
- Install: `sudo dnf install mediawriter`
- Download Aurora through the GUI

### Step 2: Create Bootable USB

```bash
# Find your USB drive
lsblk

# Write ISO (replace sdX with your USB drive!)
sudo dd if=aurora-gts-stable.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Step 3: Install Aurora

1. **Boot from USB**
2. **Start installation** (Anaconda installer)
3. **Select Installation Destination:**
   - Choose nvme1n1
   - Select **Custom partitioning**
   - Mount points:
     - `/dev/nvme1n1p1` → `/boot/efi` (EFI System)
     - `/dev/nvme1n1p2` → `/boot` (ext4)
     - `/dev/nvme1n1p3` → `/` (btrfs, subvol=root)
4. **Complete installation**
5. **Reboot**

### Step 4: Rebase to Atomic-ROCm

**First boot into Aurora:**

```bash
# Rebase to your custom image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/tlee933/atomic-rocm:latest

# Reboot into Atomic-ROCm
systemctl reboot
```

### Step 5: Post-Install Setup

**After booting into Atomic-ROCm:**

```bash
# Install Homebrew CLI tools
ujust install-brew-essentials

# Install AI/ML stack
ujust install-ml-tools

# Set up ROCm development environment
ujust setup-rocm-dev
```

### Step 6: Mount Additional Partitions

Add to `/etc/fstab`:
```bash
# Container storage (512GB)
UUID=0132ab28-2808-4914-bd67-fea959fab356 /var/lib/containers btrfs defaults,compress=zstd 0 0

# Build workspace (183GB)
UUID=06dff8e0-c8ce-4b6d-9d03-4bca0781c986 /home/hashcat/builds btrfs defaults,compress=zstd 0 0
```

Then mount:
```bash
sudo mkdir -p /var/lib/containers /home/hashcat/builds
sudo mount -a
```

---

## Alternative: Direct Rebase (If Already on Aurora/Bazzite)

If you're already running Aurora/Bazzite on nvme0n1:

```bash
# Just rebase directly
rpm-ostree rebase ostree-unverified-registry:ghcr.io/tlee933/atomic-rocm:latest
systemctl reboot
```

---

## What You Get 🎨

### KDE Plasma 6 Glassy Theme
- **Colors**: Electric blue (#1E88E5), Cyber cyan (#00BCD4), Indie purple (#7C4DFF)
- **Effects**: Blur (strength 10), 70% transparent windows, 80% transparent panel
- **Icons**: Papirus-Dark
- **Wallpapers**: AI-themed neural network and glowing orbs
- **Terminal**: Konsole with 70% transparency and blur

### Developer Tools (Aurora-DX)
- VS Code, toolchains, compilers
- Docker, Podman, Distrobox
- Git, gh CLI, lazygit
- vim, neovim, helix, tmux

### Gaming
- Steam + Proton
- GameMode + MangoHud
- vkBasalt, Goverlay

### AI/ML
- ROCm 7.11 (gfx1201 native support!)
- PyTorch ROCm backend (via Homebrew)
- Jupyter notebooks
- HuggingFace CLI

---

## Troubleshooting

### If rebase fails:
```bash
# Try with explicit transport
rpm-ostree rebase --experimental ostree-image-signed:docker://ghcr.io/tlee933/atomic-rocm:latest
```

### Check current deployment:
```bash
rpm-ostree status
```

### Roll back if needed:
```bash
rpm-ostree rollback
systemctl reboot
```

---

## Verification Commands

After deployment:
```bash
# Check ROCm
rocm-smi
/opt/rocm/bin/rocminfo

# Check GPU
clinfo
radeontop

# Check theme
kreadconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme

# Check ujust recipes
ujust --list
```

---

**Time to deploy your glassy, AI-powered, gaming beast!** 🚀✨
