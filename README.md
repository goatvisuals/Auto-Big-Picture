# Auto-Big-Picture 🎮

Automatically launch/close Steam Big Picture mode when a controller is connected or disconnected on linux.

<br>

## Features

* Works with both bluetooth and USB connections.
* *(Optional)* If Steam isn't already running it launches on controller connection.
* Keeps big picture open if a game is running when you disconnect the controller.
* Lightweight and runs in the background as a systemd service.
* Quick installer.

<br>

## Supported Distros 

[![Arch](https://img.shields.io/badge/Arch_Linux-Verified-%231793D1?logo=arch-linux&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![CachyOS](https://img.shields.io/badge/CachyOS-Verified-%2334C4B5?logo=linux&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Ubuntu](https://img.shields.io/badge/Ubuntu-Verified-%23E95420?logo=ubuntu&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Linux Mint](https://img.shields.io/badge/Linux_Mint-Verified-%2387CF3E?logo=linux-mint&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Fedora](https://img.shields.io/badge/Fedora-Verified-%23294383?logo=fedora&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Bazzite](https://img.shields.io/badge/Bazzite-Compatible-%23F4A261?logo=linux&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Nobara](https://img.shields.io/badge/Nobara-Compatible-%23F41F35?logo=linux&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Pop!_OS](https://img.shields.io/badge/Pop!_OS-Compatible-%2348B9C7?logo=pop-os&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Manjaro](https://img.shields.io/badge/Manjaro-Compatible-%2334BE8C?logo=manjaro&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues) [![Garuda](https://img.shields.io/badge/Garuda-Compatible-%23F02D64?logo=linux&logoColor=fff&style=for-the-badge)](https://github.com/goatvisuals/Auto-Big-Picture/issues)

The tool should work on most distros from the **Arch, Debian/Ubuntu, and Fedora families**. It should also play nice with derivatives like CachyOS, Mint, Nobara etc. If your distro works *(or doesn't)* let me know so I can look into it


**Setups I always test on:**

* ✅ Arch + KDE Plasma (Wayland)
* ✅ CachyOS + Hyprland (Wayland)
* ✅ Ubuntu + Gnome (Wayland)
* ✅ Mint + Cinnamon (X11)
* ✅ Fedora + KDE Plasma (Wayland)

<br>

## Supported Controllers

Tested with **Xbox Wireless Controller** both via bluetooth and USB, but should work with any controller

<br>

## Installation

<details>

<summary>Arch based</summary>

<br>

Use your fav AUR helper

```bash
yay -S auto-big-picture
```

and run ``auto-big-picture-setup`` to go through setup

<br>

> **Note:** After updates you will need to run ``auto-big-picture-setup`` again to apply the update.

<br>

</details>

<details>

<summary>Debian based</summary>

<br>

Download the latest .deb file from the [releases page](https://github.com/goatvisuals/Auto-Big-Picture/releases)

Double click the file or install with:

```bash
sudo dpkg -i auto-big-picture_X.X-X_all.deb # Replace X's to match most up to date version
```

Run the setup:

```bash
auto-big-picture-setup
```

<br>

</details>

<details>

<summary>Everyone else</summary>

<br>

Just clone the repo and run the installer script. It will guide you through the rest.

```bash
git clone https://github.com/goatvisuals/auto-big-picture.git
cd auto-big-picture
./install.sh
```
The script will handle dependencies if needed (bluez/bluez-utils for Bluetooth mode)

<br>

</details>

<br>

## Uninstall

<details>

<summary>Arch based</summary>

<br>

First run the uninstaller

```bash
auto-big-picture-uninstall
```

and remove with your AUR helper ``yay -Rns auto-big-picture``

<br>

</details>

<details>

<summary>Debian based</summary>

<br>

Run the uninstaller:

```bash
auto-big-picture-uninstall
```

Remove the package:

```bash
sudo dpkg -r auto-big-picture
```

<br>

</details>

<details>

<summary>Everyone else</summary>

<br>

Just run the uninstaller and that's it.

```bash
./uninstall.sh
```

<br>

</details>

<details>
<summary>Manual uninstall</summary>

<br>

If you prefer to manually uninstall, you can do it by stopping and disabling the service and then removing the files. The service file is always located at `~/.config/systemd/user/auto-big-picture.service`, and the config/script is by default stored in `~/.config/auto-big-picture/auto-big-picture.py` (or a different location you chose during installation).


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

</details>

<br>

## For the nerds (how does it work?)

It's a python script that uses bluetoothctl polling to check bluetooth status and periodically checks `/dev/input` for USB devices. The game check just looks for processes running from your `steamapps/common` directory to avoid closing when in game (for example if batteries die or controller goes to sleep because of inactivity)
