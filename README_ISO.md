# ISO Build Status

## Current Status: ⚠️ Deferred to GitHub Actions

Local ISO builds encounter repository connectivity issues due to Bazzite's third-party repos (charm, etc.) not being accessible from the bootc-image-builder container.

## Working Solution: GitHub Actions

The proper Universal Blue approach is to build ISOs via GitHub Actions:

1. **Add the workflow file** (already created): `.github/workflows/build-iso.yml`
2. **Push to GitHub** (via web UI to avoid OAuth scope issue)
3. **Trigger the workflow** manually or wait for weekly schedule
4. **Download ISO** from GitHub Actions artifacts

## Why This Approach?

- ✅ GitHub Actions has network access to all repos
- ✅ Matches Universal Blue's official build process
- ✅ Automated and reproducible
- ✅ No local system requirements (runs in cloud)

## Primary Installation Method

The recommended installation method is **NOT** ISO, but rather:

```bash
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest
systemctl reboot
```

This is how most Universal Blue users install custom images - from an existing Fedora Atomic desktop.

## References

- [Universal Blue ISO Build Process](https://deepwiki.com/ublue-os/bazzite/2.7-iso-build-process)
- [GitHub: ublue-os/image-template](https://github.com/ublue-os/image-template)
- [Bazzite Documentation](https://docs.bazzite.gg/)
