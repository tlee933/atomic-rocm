#!/bin/bash
set -e

echo "Creating OSTree-based bootable ISO for Atomic-ROCm..."
echo "====================================================="
echo ""

# First, we need to commit the container to an OSTree repo
# Then create an ISO from that OSTree commit

# For now, let's create a simplified approach:
# Export the container filesystem and package it

IMAGE="localhost/atomic-rocm:gfx1201"
OUTPUT_DIR="$(pwd)/output"
ISO_NAME="atomic-rocm-gfx1201.iso"

mkdir -p "$OUTPUT_DIR/ostree-export"

echo "📦 Exporting container image..."
podman create --name atomic-rocm-export $IMAGE
sudo podman export atomic-rocm-export > "$OUTPUT_DIR/atomic-rocm-export.tar"
podman rm atomic-rocm-export

echo "✅ Container exported to: $OUTPUT_DIR/atomic-rocm-export.tar"
echo ""
echo "To create bootable media, you have two options:"
echo ""
echo "1. Use rpm-ostree rebase directly (recommended):"
echo "   rpm-ostree rebase ostree-unverified-image:docker://localhost/atomic-rocm:gfx1201"
echo ""
echo "2. Create custom ISO with lorax (complex, requires OSTree repo setup)"
echo""

