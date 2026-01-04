# Atomic-ROCm Installation Guide

## Recommended: Image Rebase Method

The recommended way to install Atomic-ROCm is via `rpm-ostree rebase` from an existing Fedora Atomic desktop.

### Prerequisites
- Existing Fedora Silverblue, Kinoite, or any Universal Blue image
- AMD Radeon AI PRO R9700 GPU (gfx1201)

### Installation Steps

1. **Rebase to Atomic-ROCm:**
   ```bash
   # From local image (after pushing to ghcr.io)
   rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest
   
   # Or from local build
   rpm-ostree rebase ostree-unverified-image:docker://localhost/atomic-rocm:gfx1201
   ```

2. **Reboot:**
   ```bash
   systemctl reboot
   ```

3. **Verify Installation:**
   ```bash
   # Check system
   cat /etc/motd
   
   # Check ROCm
   ls /opt/rocm
   cat /etc/atomic-rocm-target
   
   # Check GPU (when R9700 installed)
   rocm-smi
   clinfo
   ```

## Alternative: ISO Installation (via GitHub Actions)

For fresh installations, ISOs can be generated via GitHub Actions:

### Setup GitHub Actions ISO Build

1. **Add ISO build workflow** to `.github/workflows/build-iso.yml`:
   ```yaml
   name: Build ISO
   on:
     workflow_dispatch:
     schedule:
       - cron: '0 6 * * 0'  # Weekly on Sunday
   
   jobs:
     build-iso:
       runs-on: ubuntu-latest
       permissions:
         contents: read
         packages: write
       
       steps:
         - name: Checkout
           uses: actions/checkout@v4
         
         - name: Build ISO with bootc-image-builder
           uses: ublue-os/bootc-image-builder-action@v1
           with:
             image: ghcr.io/tlee933/atomic-rocm:latest
             type: iso
             rootfs: btrfs
             
         - name: Upload ISO
           uses: actions/upload-artifact@v4
           with:
             name: atomic-rocm-iso
             path: output/*.iso
   ```

2. **Trigger the workflow** via GitHub web UI
3. **Download the ISO** from Actions artifacts
4. **Write to USB:**
   ```bash
   sudo dd if=atomic-rocm.iso of=/dev/sdX bs=4M status=progress
   ```

## Local ISO Build (Advanced)

Local ISO builds may fail due to repository connectivity issues. This is because Bazzite includes third-party repos (charm, etc.) that may not be accessible from build containers.

**If you need local ISO builds**, use the GitHub Actions method or:

1. Modify the Containerfile to remove problematic repos
2. Rebuild the image without those repos
3. Then run bootc-image-builder

## Troubleshooting

### Rebase Method

**Issue:** Image not found
```bash
# Pull the image first
podman pull ghcr.io/tlee933/atomic-rocm:latest

# Then rebase
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest
```

**Issue:** Unsigned image warning
- This is expected - we're using `ostree-unverified-image`
- For production, set up image signing with cosign

### ISO Build Method

**Issue:** Repository errors (charm, etc.)
- Use GitHub Actions instead of local builds
- Or modify Containerfile to remove third-party repos

**Issue:** bootc-image-builder fails
- Ensure image is in root's podman storage: `sudo podman images`
- Check available space: `df -h`

## Post-Installation

1. **Update the system:**
   ```bash
   rpm-ostree upgrade
   systemctl reboot
   ```

2. **Install PyTorch (in Distrobox):**
   ```bash
   distrobox create --name ai-dev --image fedora:42
   distrobox enter ai-dev
   pip install torch torchvision --index-url https://download.pytorch.org/whl/rocm6.0
   ```

3. **Test GPU compute:**
   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   ```

## References

- [Universal Blue Documentation](https://universal-blue.org/)
- [Bazzite Documentation](https://docs.bazzite.gg/)
- [ROCm Documentation](https://rocm.docs.amd.com/)
