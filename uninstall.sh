#!/bin/bash

echo "Uninstalling Auto-Big-Picture"

echo "Stopping and disabling systemd service..."
systemctl --user stop auto-big-picture.service
systemctl --user disable auto-big-picture.service

echo "Removing files..."
rm -f "$HOME/.config/systemd/user/auto-big-picture.service"
rm -f "$HOME/scripts/auto_big_picture.py"

echo "Reloading systemd daemon..."
systemctl --user daemon-reload

echo ""
echo "Uninstallation complete"
