#!/bin/bash
set -e

SERVICE_NAME="rtsp-stream"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/${SERVICE_NAME}.service"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

echo "=== Installing ${SERVICE_NAME} systemd service ==="

# Copy service file
cp "$SERVICE_FILE" /etc/systemd/system/${SERVICE_NAME}.service

# Reload and enable
systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.service
systemctl start ${SERVICE_NAME}.service

echo ""
echo "Service installed and started!"
echo "  Status : sudo systemctl status ${SERVICE_NAME}"
echo "  Logs   : sudo journalctl -u ${SERVICE_NAME} -f"
echo "  Stream : rtsp://$(hostname -I | awk '{print $1}'):8554/cam"
