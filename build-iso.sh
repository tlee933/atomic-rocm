#!/bin/bash
set -e

echo "🚀 Building Atomic-ROCm bootable ISO..."
echo "============================================"
echo ""

# Configuration
IMAGE="localhost/atomic-rocm:gfx1201"
OUTPUT_DIR="$(pwd)/output"
ISO_NAME="atomic-rocm-gfx1201.iso"

echo "Image:       $IMAGE"
echo "Output dir:  $OUTPUT_DIR"
echo "ISO name:    $ISO_NAME"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Use bootc-image-builder container
echo "📦 Pulling bootc-image-builder..."
sudo podman pull quay.io/centos-bootc/bootc-image-builder:latest

echo ""
echo "🔨 Building ISO (this will take 10-20 minutes)..."
echo ""

# Build the ISO
sudo podman run \
    --rm \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v "$OUTPUT_DIR:/output" \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type iso \
    --local \
    "$IMAGE"

echo ""
echo "✅ ISO build complete!"
echo "📀 ISO location: $OUTPUT_DIR/$ISO_NAME"
echo ""
echo "To write to USB:"
echo "  sudo dd if=$OUTPUT_DIR/bootiso/install.iso of=/dev/sdX bs=4M status=progress"
echo ""

