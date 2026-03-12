#!/bin/bash

validate_mac() {
    local mac="$1"
    [[ "$mac" == "DISABLED" ]] && return 0
    [[ "$mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]
}

select_controller() {
    echo "Scanning for bluetooth devices..."
    mapfile -t devices_array < <(bluetoothctl devices Paired 2>/dev/null | awk '{print $2, substr($0, index($0,$3))}')

    if [ ${#devices_array[@]} -eq 0 ]; then
        echo "No paired bluetooth devices found."
        echo "Pair your controller first or choose the USB-only option."
        read -rp "Enter your controller's MAC Address (or leave blank to cancel): " CONTROLLER_MAC
        return
    fi

    echo "Select your controller from the list:"
    select device_info in "${devices_array[@]}" "Enter_Manually"; do
        if [[ "$device_info" == "Enter_Manually" ]]; then
            read -rp "Enter your controller's MAC Address: " CONTROLLER_MAC
            break
        elif [ -n "$device_info" ]; then
            CONTROLLER_MAC=$(echo "$device_info" | awk '{print $1}')
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
}

echo "Auto-Big-Picture Setup"

echo "Choose your installation type:"
select installation_type in "Bluetooth_and_USB" "USB_Only"; do
    case $installation_type in
        "Bluetooth_and_USB")
            echo "Checking for bluetoothctl (required for Bluetooth mode)..."
            if command -v pacman &> /dev/null; then
                PACKAGE="bluez-utils"
                if ! pacman -Q "$PACKAGE" &> /dev/null; then
                    echo "Installing '$PACKAGE'..."
                    sudo pacman -S --noconfirm "$PACKAGE"
                else
                    echo "'$PACKAGE' is already installed."
                fi
            elif command -v apt &> /dev/null; then
                PACKAGE="bluez"
                if ! dpkg -s "$PACKAGE" &> /dev/null; then
                    echo "Installing '$PACKAGE'..."
                    sudo apt update && sudo apt install -y "$PACKAGE"
                else
                    echo "'$PACKAGE' is already installed."
                fi
            elif command -v dnf &> /dev/null; then
                PACKAGE="bluez"
                if ! dnf list installed "$PACKAGE" &> /dev/null; then
                    echo "Installing '$PACKAGE'..."
                    sudo dnf install -y "$PACKAGE"
                else
                    echo "'$PACKAGE' is already installed."
                fi
            else
                echo "Warning: Could not detect package manager. Manually install bluetoothctl (part of BlueZ)."
            fi
            select_controller
            if [ -z "$CONTROLLER_MAC" ]; then
                echo "Error: MAC Address selection failed. Aborting."
                exit 1
            fi
            if ! validate_mac "$CONTROLLER_MAC"; then
                echo "Error: Invalid MAC address format. Use XX:XX:XX:XX:XX:XX or 'DISABLED'."
                exit 1
            fi
            break
            ;;
        "USB_Only")
            CONTROLLER_MAC="DISABLED"
            break
            ;;
        *)
            echo "Invalid selection. Choose 1 or 2."
            ;;
    esac
done

echo "Using MAC Address: $CONTROLLER_MAC"

echo "When a controller connects, should the script launch Steam if it wasn't already running?"
select launch_behavior in "Yes_Launch_Steam" "No_Only_if_Already_Running"; do
    case $launch_behavior in
        "Yes_Launch_Steam")
            LAUNCH_PREFERENCE="True"
            break
            ;;
        "No_Only_if_Already_Running")
            LAUNCH_PREFERENCE="False"
            break
            ;;
        *)
            echo "Invalid selection. Choose 1 or 2."
            ;;
    esac
done

echo "Launch Steam on controller connection if it was closed? $LAUNCH_PREFERENCE"

CONFIG_DIR="$HOME/.config/auto-big-picture"
read -rp "Default config path: $CONFIG_DIR. Change? Input path or leave blank to keep default: " custom_path

if [ -n "$custom_path" ]; then
    if echo "$custom_path" | grep -qE '[;$(`{}*?<>|&[:space:]]' || [[ -L "$custom_path" ]]; then
        echo "Error: Unsafe config path. Contains forbidden chars or is a symlink."
        exit 1
    fi
    CONFIG_DIR="$custom_path"
fi

CONFIG_DIR=$(realpath -m "$CONFIG_DIR") || { echo "Invalid path."; exit 1; }

TEMPLATE_DIR="."
if [ -d "/usr/share/auto-big-picture" ]; then
    TEMPLATE_DIR="/usr/share/auto-big-picture"
fi

echo "Creating directories..."
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"
mkdir -p "$HOME/.config/systemd/user"

echo "Configuring and copying files..."

PYTHON_CMD=$(command -v python3 || command -v python)
if [ -z "$PYTHON_CMD" ]; then
    echo "Error: python3 required."
    exit 1
fi

"$PYTHON_CMD" -c "
import sys, os
mac = '''$CONTROLLER_MAC'''
launch = '''$LAUNCH_PREFERENCE'''
template_dir = '''$TEMPLATE_DIR'''
config_dir = '''$CONFIG_DIR'''

try:
    with open(os.path.join(template_dir, 'auto-big-picture.py.template')) as f:
        src = f.read()
except FileNotFoundError:
    sys.stderr.write('Error: auto-big-picture.py.template not found.\n')
    sys.exit(1)

with open(os.path.join(config_dir, 'auto-big-picture.py'), 'w') as out:
    out.write(src.replace('__CONTROLLER_MAC_ADDRESS__', mac).replace('__LAUNCH_PREFERENCE__', launch))
"

SCRIPT_PATH="$CONFIG_DIR/auto-big-picture.py"

"$PYTHON_CMD" -c "
import os, re
mac = '''$CONTROLLER_MAC'''
script_path = '''$SCRIPT_PATH'''
template_dir = '''$TEMPLATE_DIR'''

service_content = open(os.path.join(template_dir, 'auto-big-picture.service.template')).read()
safe_script = script_path.replace(\"'\", \"'\" + chr(39) + \"'\")
service_content = service_content.replace('__SCRIPT_PATH__', safe_script)

if mac != 'DISABLED':
    service_content = re.sub(
        r'(After=graphical-session\.target)',
        r'After=\1 bluetooth.service',
        service_content,
        count=1
    )

os.makedirs(os.path.expanduser('~/.config/systemd/user'), exist_ok=True)
with open(os.path.expanduser('~/.config/systemd/user/auto-big-picture.service'), 'w') as f:
    f.write(service_content)
"

chmod +x "$SCRIPT_PATH"
echo "Reloading systemd and starting the service..."
systemctl --user daemon-reload
systemctl --user enable --now auto-big-picture.service
echo ""
systemctl --user status auto-big-picture.service --no-pager -l || true
echo ""
echo "Setup complete!"
