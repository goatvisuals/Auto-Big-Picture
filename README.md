# Auto-Big-Picture 🎮

Automatically launch/close Steam big picture mode when a controller is connected or disconnected on linux.

<br>

## Features

* Works with both bluetooth and USB connections.
* *(Optional)* If Steam isn't already running it launches in big picture mode
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
The script will handle dependencies (python-dbus) and if you use the bluetooth installation type it lets you pick your controller from a list of paired devices.


<br>

## Uninstall

Just run the uninstaller.

```bash
./uninstall.sh
```

<br>

## For the nerds (how does it work?)

It's a python script that uses d-bus to listen for bluetooth events and periodically checks `/dev/input` for USB devices. The game check just looks for processes running from your `steamapps/common` directory to avoid closing when in game (for example if batteries die or controller goes to sleep because of inactivity)
