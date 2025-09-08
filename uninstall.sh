#!/bin/bash

echo "Uninstalling Auto-Big-Picture"

echo "Stopping and disabling systemd service..."
systemctl --user stop auto-big-picture.service
systemctl --user disable auto-big-picture.service

echo "Removing files..."
SERVICE_FILE="$HOME/.config/systemd/user/auto-big-picture.service"
SCRIPT_PATH=$(grep '^ExecStart=' "$SERVICE_FILE" | cut -d= -f2-)
rm -f "$SERVICE_FILE"
rm -f "$SCRIPT_PATH"
DEFAULT_DIR="$HOME/.config/auto-big-picture"
DIR=$(dirname "$SCRIPT_PATH")
if [ "$DIR" = "$DEFAULT_DIR" ] && [ -d "$DIR" ]; then
    rmdir "$DIR" 2>/dev/null || true
fi

echo "Reloading systemd daemon..."
systemctl --user daemon-reload

echo ""
echo "Uninstallation complete"
