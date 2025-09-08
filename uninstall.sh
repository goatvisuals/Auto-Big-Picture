#!/bin/bash

echo "Uninstalling Auto-Big-Picture"

echo "Stopping and disabling systemd service..."
systemctl --user stop steam-controller-handler.service
systemctl --user disable steam-controller-handler.service

echo "Removing files..."
rm -f "$HOME/.config/systemd/user/steam-controller-handler.service"
rm -f "$HOME/scripts/steam_controller_handler.py"

echo "Reloading systemd daemon..."
systemctl --user daemon-reload

echo ""
echo "Uninstallation complete"
