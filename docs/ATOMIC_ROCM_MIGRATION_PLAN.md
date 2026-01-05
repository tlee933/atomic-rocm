# Atomic-ROCm Migration Plan

**Date:** 2026-01-04  
**Current:** Fedora 43 (Standard)  
**Target:** Atomic-ROCm (Immutable Bazzite-based)  
**Hardware:** 2x NVMe drives + 11TB NAS  

---

## Executive Summary

**Strategy:** Clean install Atomic-ROCm on nvme1n1 (1TB), use NAS for data migration.

**Why Clean Install vs Rebase:**
- ✅ Fresh start on faster, larger drive (nvme1n1)
- ✅ Optimal partition layout for immutable OS
- ✅ Migrate from 94% full drive to fresh 1TB drive
- ✅ Keep current system bootable as fallback
- ✅ Test Atomic-ROCm before committing

---

## Partition Layout Design

### nvme1n1 (1TB) - Primary System Drive

```
┌─────────────────────────────────────────────────────┐
│ /dev/nvme1n1                                        │
├─────────────────────────────────────────────────────┤
│ nvme1n1p1: 1GB    - EFI System Partition (FAT32)   │
│ nvme1n1p2: 2GB    - /boot (ext4)                    │
│ nvme1n1p3: 256GB  - Root + Home (btrfs)             │
│ nvme1n1p4: 512GB  - Container Storage (btrfs)       │
│ nvme1n1p5: 230GB  - Build Workspace (btrfs)         │
├─────────────────────────────────────────────────────┤
│ Total: 1001GB allocated                             │
└─────────────────────────────────────────────────────┘
```

#### Partition Details

**p1: EFI (1GB, FAT32)**
- Mount: /boot/efi
- Purpose: UEFI bootloader
- Larger than typical (512MB) for multiple bootloaders

**p2: /boot (2GB, ext4)**
- Mount: /boot
- Purpose: Kernel images, initramfs
- rpm-ostree requires separate /boot
- 2GB allows ~10 kernel versions

**p3: Root + Home (256GB, btrfs)**
- Mount: / (with subvolumes)
- Subvolumes:
  - `@` → / (root)
  - `@home` → /home
  - `@snapshots` → /.snapshots (for snapper/timeshift)
- Btrfs features:
  - Transparent compression (zstd:3)
  - COW for snapshots
  - Deduplication
- Expected usage:
  - System: ~30GB (Atomic-ROCm + apps)
  - Home: ~150GB (user data, configs)
  - Snapshots: ~50GB (rollback insurance)
  - Free: ~26GB buffer

**p4: Container Storage (512GB, btrfs)**
- Mount: /var/lib/containers
- Purpose: Podman images, distrobox containers
- Dedicated partition prevents container bloat from affecting system
- Expected usage:
  - Atomic-ROCm image cache: ~13GB
  - Distrobox containers (AI/ML): ~50GB
  - Build containers: ~100GB
  - Layered images: ~150GB
  - Free: ~199GB for growth

**p5: Build Workspace (230GB, btrfs)**
- Mount: /mnt/builds
- Purpose: TheRock builds, compilation artifacts
- Currently using 119GB on nvme1n1p1
- Room to grow

---

### nvme0n1 (500GB) - Secondary Fast Storage

```
┌─────────────────────────────────────────────────────┐
│ /dev/nvme0n1                                        │
├─────────────────────────────────────────────────────┤
│ nvme0n1p1: 200GB  - Game Library (ext4)             │
│ nvme0n1p2: 200GB  - AI Model Cache (ext4)           │
│ nvme0n1p3: 100GB  - VM Images (ext4)                │
├─────────────────────────────────────────────────────┤
│ Total: 500GB allocated                              │
└─────────────────────────────────────────────────────┘
```

**Purpose:** Fast storage for read-heavy workloads
- Steam library (fast game loading)
- AI model cache (fast inference)
- VM images (fast boot)

---

### NAS (11TB) - Bulk Storage & Backups

```
/mnt/ai/
├── llm-models/           # 1.3TB - LLM models (ollama, llama.cpp)
├── ai-datasets/          # Future - Training datasets
├── backups/              # System backups, snapshots
│   ├── atomic-rocm/      # OSTree snapshots
│   ├── home/             # Home directory backups
│   └── containers/       # Container image backups
├── media/                # Videos, music, photos
├── projects/             # Archive of completed projects
└── huggingface-cache/    # Model repository
```

**NFS Mount Options (optimized):**
```
192.168.1.7:/moar/ai-pfsense /mnt/ai nfs \
  rw,relatime,vers=4,rsize=1048576,wsize=1048576, \
  hard,timeo=600,retrans=2,nconnect=4,_netdev 0 0
```

---

## Migration Steps

### Phase 1: Preparation (1-2 hours)

**1.1: Backup Current System to NAS**
```bash
# Create backup directory
sudo mkdir -p /mnt/ai/backups/fedora43-$(date +%Y%m%d)

# Backup home directory (exclude cache)
rsync -aAXv --exclude='.cache' /home/hashcat/ \
  /mnt/ai/backups/fedora43-$(date +%Y%m%d)/home/

# Backup critical configs
sudo rsync -aAXv /etc/ \
  /mnt/ai/backups/fedora43-$(date +%Y%m%d)/etc/

# Backup /opt (if any custom software)
sudo rsync -aAXv /opt/ \
  /mnt/ai/backups/fedora43-$(date +%Y%m%d)/opt/

# List installed packages
rpm -qa > /mnt/ai/backups/fedora43-$(date +%Y%m%d)/package-list.txt
```

**1.2: Backup TheRock Build Workspace**
```bash
# Rsync build workspace to NAS
sudo rsync -aAXv --info=progress2 \
  /mnt/therock-build/ \
  /mnt/ai/backups/therock-build-$(date +%Y%m%d)/
```

**1.3: Document Current Setup**
```bash
# Save partition layout
lsblk > ~/current-partitions.txt
sudo fdisk -l >> ~/current-partitions.txt

# Save mount points
cat /proc/mounts > ~/current-mounts.txt

# Save fstab
cat /etc/fstab > ~/current-fstab.txt

# Copy to NAS
cp ~/*.txt /mnt/ai/backups/fedora43-$(date +%Y%m%d)/
```

---

### Phase 2: Partition nvme1n1 (30 minutes)

**2.1: Boot from Live USB**
- Use Fedora Live or SystemRescue

**2.2: Wipe and Partition nvme1n1**
```bash
# WARNING: This erases nvme1n1!
sudo sgdisk --zap-all /dev/nvme1n1

# Create GPT partition table
sudo sgdisk --clear /dev/nvme1n1

# Create partitions
sudo sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" /dev/nvme1n1          # EFI
sudo sgdisk -n 2:0:+2G -t 2:8300 -c 2:"boot" /dev/nvme1n1         # /boot
sudo sgdisk -n 3:0:+256G -t 3:8300 -c 3:"system" /dev/nvme1n1     # Root+Home
sudo sgdisk -n 4:0:+512G -t 4:8300 -c 4:"containers" /dev/nvme1n1 # Containers
sudo sgdisk -n 5:0:0 -t 5:8300 -c 5:"builds" /dev/nvme1n1         # Builds (rest)

# Verify
sudo sgdisk -p /dev/nvme1n1
```

**2.3: Format Partitions**
```bash
# EFI
sudo mkfs.vfat -F32 -n EFI /dev/nvme1n1p1

# Boot
sudo mkfs.ext4 -L boot /dev/nvme1n1p2

# System (btrfs with subvolumes)
sudo mkfs.btrfs -L system /dev/nvme1n1p3
sudo mount /dev/nvme1n1p3 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt

# Containers
sudo mkfs.btrfs -L containers /dev/nvme1n1p4

# Builds
sudo mkfs.btrfs -L builds /dev/nvme1n1p5
```

---

### Phase 3: Install Atomic-ROCm (1 hour)

**Option A: From Local Image (Recommended)**
```bash
# From running Fedora 43 (nvme0n1 still intact)
rpm-ostree rebase ostree-unverified-image:docker://localhost/atomic-rocm:gfx1201

# Or from ghcr.io
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/tlee933/atomic-rocm:latest

# Reboot
systemctl reboot
```

**Option B: From ISO (if available from GitHub Actions)**
```bash
# Boot from Atomic-ROCm ISO
# Select installation target: /dev/nvme1n1
# Installer handles partitioning automatically
```

---

### Phase 4: Post-Install Configuration (2 hours)

**4.1: Mount Additional Partitions**

Edit `/etc/fstab`:
```bash
# nvme1n1 - System partitions
UUID=<nvme1n1p1>  /boot/efi          vfat    defaults,umask=0077  0 2
UUID=<nvme1n1p2>  /boot              ext4    defaults             0 2
UUID=<nvme1n1p3>  /                  btrfs   subvol=@,compress=zstd:3,noatime  0 1
UUID=<nvme1n1p3>  /home              btrfs   subvol=@home,compress=zstd:3,noatime  0 2
UUID=<nvme1n1p3>  /.snapshots        btrfs   subvol=@snapshots,compress=zstd:3,noatime  0 2
UUID=<nvme1n1p4>  /var/lib/containers btrfs  compress=zstd:3,noatime  0 2
UUID=<nvme1n1p5>  /mnt/builds        btrfs   compress=zstd:3,noatime  0 2

# nvme0n1 - Secondary storage
UUID=<nvme0n1p1>  /mnt/games         ext4    defaults,noatime     0 2
UUID=<nvme0n1p2>  /mnt/ai-cache      ext4    defaults,noatime     0 2
UUID=<nvme0n1p3>  /mnt/vms           ext4    defaults,noatime     0 2

# NAS
192.168.1.7:/moar/ai-pfsense  /mnt/ai  nfs  rw,vers=4,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,nconnect=4,_netdev  0 0
```

**4.2: Restore User Data**
```bash
# Restore home directory
rsync -aAXv /mnt/ai/backups/fedora43-20260104/home/ /home/hashcat/

# Restore configs (selective)
sudo rsync -aAXv /mnt/ai/backups/fedora43-20260104/etc/ssh/ /etc/ssh/
sudo rsync -aAXv /mnt/ai/backups/fedora43-20260104/etc/NetworkManager/ /etc/NetworkManager/
```

**4.3: Restore TheRock Build Workspace**
```bash
sudo rsync -aAXv --info=progress2 \
  /mnt/ai/backups/therock-build-20260104/ \
  /mnt/builds/TheRock/
```

**4.4: Set up Distrobox for AI/ML**
```bash
# Create AI development container
distrobox create --name ai-dev --image fedora:42

# Enter and setup PyTorch
distrobox enter ai-dev
pip install torch torchvision --index-url https://download.pytorch.org/whl/rocm6.0
```

**4.5: Configure Steam Library (on nvme0n1)**
```bash
# In Steam settings, add library folder:
# /mnt/games/SteamLibrary
```

**4.6: Move AI Models to nvme0n1 Cache**
```bash
# Link frequently used models to fast cache
mkdir -p /mnt/ai-cache/huggingface
ln -s /mnt/ai-cache/huggingface ~/.cache/huggingface
```

---

### Phase 5: Optimization & Testing (1 hour)

**5.1: Enable Btrfs Auto-Snapshots**
```bash
# Install snapper
rpm-ostree install snapper

# Create config
sudo snapper -c root create-config /
sudo snapper -c home create-config /home

# Take initial snapshot
sudo snapper -c root create --description "Fresh Atomic-ROCm install"
```

**5.2: Test GPU**
```bash
# Check ROCm
rocm-smi
clinfo

# Test PyTorch (in distrobox)
distrobox enter ai-dev
python -c "import torch; print(torch.cuda.is_available())"
```

**5.3: Test Gaming**
```bash
# Launch Steam
steam

# Test a game from /mnt/games
```

**5.4: Benchmark New Setup**
```bash
# Test nvme1n1 performance
sudo fio --name=test --filename=/dev/nvme1n1 --direct=1 --rw=read --bs=1M --size=1G --runtime=5
```

---

## Rollback Plan

**If Atomic-ROCm doesn't work:**

1. **Old system still intact on nvme0n1**
   - Change boot order in BIOS to nvme0n1
   - Boot back to Fedora 43

2. **All data backed up on NAS**
   - Restore from `/mnt/ai/backups/`

3. **Can try again**
   - nvme1n1 can be repartitioned
   - No data loss

---

## Timeline

| Phase | Duration | Total |
|-------|----------|-------|
| Preparation & Backup | 1-2h | 1-2h |
| Partition nvme1n1 | 30m | 2-2.5h |
| Install Atomic-ROCm | 1h | 3-3.5h |
| Post-Install Config | 2h | 5-5.5h |
| Optimization & Testing | 1h | 6-6.5h |

**Total Migration Time:** 6-7 hours (can be done over weekend)

---

## Success Criteria

✅ Atomic-ROCm boots and runs smoothly on nvme1n1  
✅ ROCm 7.11 detects GPU and works correctly  
✅ Gaming works (Steam library on nvme0n1)  
✅ AI/ML workflows functional (distrobox, PyTorch)  
✅ TheRock builds work from /mnt/builds  
✅ NAS storage accessible and performant  
✅ Old system accessible as fallback  

---

## Post-Migration Cleanup (Optional)

**After 1 week of successful Atomic-ROCm usage:**

1. **Repurpose nvme0n1 for new layout:**
   ```bash
   # Wipe nvme0n1 (after confirming migration success!)
   sudo sgdisk --zap-all /dev/nvme0n1
   
   # Create new layout (games, cache, VMs)
   # As designed above
   ```

2. **Move NAS backups to long-term archive**

3. **Remove old Fedora 43 backups from NAS**
   ```bash
   # After 30 days of stable Atomic-ROCm
   sudo rm -rf /mnt/ai/backups/fedora43-20260104
   ```

---

## Notes

**Btrfs Compression Benefits:**
- Saves ~30-40% disk space
- Slight CPU overhead (minimal on modern CPUs)
- zstd:3 is sweet spot (good compression, fast)

**Why Separate Container Partition:**
- Prevents container bloat from filling root
- Can be wiped/rebuilt without affecting system
- Easier to monitor container storage usage

**NAS Performance:**
- NFS v4 with nconnect=4 provides good throughput
- Keep frequently accessed data on NVMe
- Use NAS for bulk storage and backups

