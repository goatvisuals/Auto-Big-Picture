# Auto-Big-Picture 🎮

Automatically launch/close Steam big picture mode when a controller is connected or disconnected on linux.

<br>

## Features

* Works with both bluetooth and USB connections.
* *(Optional)* If Steam isn't already running it launches on controller connection.
* Keeps big picture open if a game is running when you disconnect the controller.
* Lightweight and runs in the background as a systemd service.
* Quick installer.

<br>

## Supported Distros

This was built and tested on **Arch btw**, but the installer will work on most distros:

* **Arch**
* **Debian / Ubuntu**
* **Fedora**

It should also work on any derivatives of these (like CachyOS, Mint, Nobara, etc.). If your distro isn't listed and it works *(or doesn't)*, feel free to open an issue

<br>

## Supported Controllers

Tested with **Xbox Wireless Controller** both via bluetooth and USB, but should work with any controller

<br>

## Installation

Just clone the repo and run the installer script. It will guide you through the rest.

```bash
git clone https://github.com/goatvisuals/Auto-Big-Picture
cd Auto-Big-Picture
./install.sh
```
The script will handle dependencies if needed (bluez/bluez-utils for Bluetooth mode)


<br>

> **Options during install:**

**Step 1: Installation type**

1: Install for Bluetooth and USB connections

2: Install for USB connections only


<br>

**Step 1.5: *Only for bluetooth installation type***

Choose controller from list of paired devices


<br>

**Step 2: Should steam launch when a controller gets connected even if it isn't already running?**

1: Yes - launches even if steam wasn't running

2: No - only start big picture when the steam process is already running


<br>

**Step 3: Change config path**

Input custom path or leave blank to keep the default

``~/.config/auto-big-picture``


<br>

## Uninstall

Just run the uninstaller and that's it.

```bash
./uninstall.sh
```


<br>


> **Note**: If you prefer to manually uninstall, you can do it by stopping and disabling the service and then removing the files. The service file is always located at `~/.config/systemd/user/auto-big-picture.service`, and the config/script is by default stored in `~/.config/auto-big-picture/auto-big-picture.py` (or a different location you chose during installation).


**1 Stop and disable the service:**
```bash
systemctl --user stop auto-big-picture.service
systemctl --user disable auto-big-picture.service
```

**2 Reload systemd:**
```bash
systemctl --user daemon-reload
```

**3 Remove the files (change last 2 paths if you chose a custom config dir):**
```bash
rm -f ~/.config/systemd/user/auto-big-picture.service
rm -f ~/.config/auto-big-picture/auto-big-picture.py
rmdir ~/.config/auto-big-picture
```

<br>

## For the nerds (how does it work?)

It's a python script that uses bluetoothctl polling to check bluetooth status and periodically checks `/dev/input` for USB devices. The game check just looks for processes running from your `steamapps/common` directory to avoid closing when in game (for example if batteries die or controller goes to sleep because of inactivity)
