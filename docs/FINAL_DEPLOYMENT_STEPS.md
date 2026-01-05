# Atomic-ROCm Deployment - Final Steps 🎯

## What's Ready

✅ **Image**: ghcr.io/tlee933/atomic-rocm:latest (pushed to GitHub)  
✅ **Base**: Aurora-DX (KDE Plasma 6 + Dev Tools)  
✅ **Disk**: nvme1n1 partitioned & formatted  
✅ **Theming**: Glassy blue/cyan/purple configured  
✅ **ROCm**: 7.11 custom build for R9700 (gfx1201)  

## Quick Deployment

### Option 1: Download & Install (Recommended)

1. **Download Fedora Kinoite 42:**
   - Official page: https://fedoraproject.org/kinoite/download/
   - Direct ISO: https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Kinoite/x86_64/iso/Fedora-Kinoite-ostree-x86_64-42-1.1.iso
   - Size: ~3.5 GB

2. **Write to USB:**
   ```bash
   sudo dd if=Fedora-Kinoite-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```

3. **Install to nvme1n1:**
   - Boot from USB
   - Custom partitioning:
     - `/dev/nvme1n1p1` → `/boot/efi`
     - `/dev/nvme1n1p2` → `/boot`
     - `/dev/nvme1n1p3` → `/` (btrfs, subvol=root)
   - Complete installation

4. **Rebase to Atomic-ROCm:**
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/tlee933/atomic-rocm:latest
   systemctl reboot
   ```

5. **Post-install:**
   ```bash
   # Install Homebrew tools
   ujust install-brew-essentials
   
   # Install AI/ML stack
   ujust install-ml-tools
   
   # Set up ROCm dev environment
   ujust setup-rocm-dev
   ```

### Option 2: If Already on Kinoite/Aurora/Bazzite

Just rebase directly:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/tlee933/atomic-rocm:latest
systemctl reboot
```

## What You Get

🎨 **Glassy KDE Plasma 6** - Blur, transparency, Papirus icons  
💻 **Aurora-DX Tools** - VS Code, Docker, Git, dev toolchains  
🎮 **Gaming** - Steam, GameMode, MangoHud, Proton  
🤖 **AI/ML** - ROCm 7.11, PyTorch, Jupyter, HuggingFace  

## Mount Additional Partitions

After first boot, add to `/etc/fstab`:
```
UUID=0132ab28-2808-4914-bd67-fea959fab356 /var/lib/containers btrfs defaults,compress=zstd 0 0
UUID=06dff8e0-c8ce-4b6d-9d03-4bca0781c986 /home/hashcat/builds btrfs defaults,compress=zstd 0 0
```

Then: `sudo mkdir -p /var/lib/containers /home/hashcat/builds && sudo mount -a`

---

**Everything's ready when you are!** 🚀

GitHub Repo: https://github.com/tlee933/atomic-rocm  
Container Image: ghcr.io/tlee933/atomic-rocm:latest
