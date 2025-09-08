#!/bin/bash

# Find and select bluetooth controller
select_controller() {
    echo "Scanning for bluetooth devices..."
    mapfile -t devices_array < <(bluetoothctl devices Paired | awk '{print $2, substr($0, index($0,$3))}')
    
    if [ ${#devices_array[@]} -eq 0 ]; then
        echo "No paired bluetooth devices found."
        echo "Pair your controller first or choose the USB-only option."
        read -p "Enter your controller's MAC Address (or leave blank to cancel): " CONTROLLER_MAC
        return
    fi

    echo "Select your controller from the list:"
    select device_info in "${devices_array[@]}" "Enter_Manually"; do
        if [[ "$REPLY" == "Enter_Manually" ]]; then
            read -p "Enter your controller's MAC Address: " CONTROLLER_MAC
            break
        elif [ -n "$device_info" ]; then
            CONTROLLER_MAC=$(echo "$device_info" | awk '{print $1}')
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
}

# Main
echo "Auto-Big-Picture Setup"

echo "Choose your installation type:"
select installation_type in "Bluetooth_and_USB" "USB_Only"; do
    case $installation_type in
        "Bluetooth_and_USB")
            select_controller
            if [ -z "$CONTROLLER_MAC" ]; then
                echo "Error: MAC Address selection failed. Aborting."
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

echo "Checking for dependencies..."
if command -v pacman &> /dev/null; then
    PACKAGE="python-dbus"
    if ! pacman -Q "$PACKAGE" &> /dev/null; then
        echo "Installing '$PACKAGE'..."
        sudo pacman -S --noconfirm "$PACKAGE"
    else
        echo "'$PACKAGE' is already installed."
    fi
elif command -v apt &> /dev/null; then
    PACKAGE="python3-dbus"
    if ! dpkg -s "$PACKAGE" &> /dev/null; then
        echo "Installing '$PACKAGE'..."
        sudo apt update && sudo apt install -y "$PACKAGE"
    else
        echo "'$PACKAGE' is already installed."
    fi
elif command -v dnf &> /dev/null; then
    PACKAGE="python3-dbus"
    if ! dnf list installed "$PACKAGE" &> /dev/null; then
        echo "Installing '$PACKAGE'..."
        sudo dnf install -y "$PACKAGE"
    else
        echo "'$PACKAGE' is already installed."
    fi
else
    echo "Warning: Could not detect package manager. Make sure 'dbus-python' is installed."
fi

echo "Creating directories..."
mkdir -p "$HOME/scripts"
mkdir -p "$HOME/.config/systemd/user"

echo "Configuring and copying files..."
sed -e "s/__CONTROLLER_MAC_ADDRESS__/$CONTROLLER_MAC/g" \
    -e "s/__LAUNCH_PREFERENCE__/$LAUNCH_PREFERENCE/g" \
    auto_big_picture.py.template > "$HOME/scripts/auto_big_picture.py"

sed "s|__HOME__|$HOME|g" auto-big-picture.service.template > "$HOME/.config/systemd/user/auto-big-picture.service"
chmod +x "$HOME/scripts/auto_big_picture.py"

echo "Reloading systemd and starting the service..."
systemctl --user daemon-reload
systemctl --user enable --now auto-big-picture.service

systemctl --user status auto-big-picture.service
echo ""
echo "Setup complete!"
echo "The service running. Connect your controller and enjoy."
