#!/bin/bash
set -e

MEDIAMTX_VERSION="v1.16.3"
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== RTSP Stream Setup for Raspberry Pi 5 ==="
echo "Install directory: $INSTALL_DIR"

# Download MediaMTX
echo ""
echo "[1/3] Downloading MediaMTX ${MEDIAMTX_VERSION} (ARM64)..."
wget -q --show-progress -O /tmp/mediamtx.tar.gz \
  "https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_arm64.tar.gz"

# Extract binary only (we use our own config)
echo "[2/3] Extracting MediaMTX binary..."
tar -xzf /tmp/mediamtx.tar.gz -C "$INSTALL_DIR" mediamtx
chmod +x "$INSTALL_DIR/mediamtx"
rm /tmp/mediamtx.tar.gz

# Apply UDP buffer tuning for stable streaming
echo "[3/3] Applying network buffer tuning..."
sudo tee /etc/sysctl.d/99-mediamtx-buffers.conf > /dev/null <<EOF
net.core.rmem_default=1000000
net.core.rmem_max=1000000
EOF
sudo sysctl --system > /dev/null 2>&1

echo ""
echo "Setup complete! Next steps:"
echo "  1. Run: sudo bash install_service.sh"
echo "  2. The stream will be available at: rtsp://<this-pi-ip>:8554/cam"
