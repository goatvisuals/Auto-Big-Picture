---
name: Bug Report
about: Create a bug report to improve the script
title: "[BUG]"
labels: ''
assignees: goatvisuals

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Start Steam in '...' mode (e.g., Desktop, Big Picture)
2. Connect the controller using '...' (e.g., Bluetooth, USB)
3. Disconnect the controller by '...' (e.g., turning it off, unplugging it)
4. The issue I see is '...'

**Expected behavior**
A clear and concise description of what you expected to happen.

**System Information:**
* **Linux Distribution:** (e.g., Arch Linux, Ubuntu 24.04)
* **Desktop Environment:** (e.g., GNOME 46, KDE Plasma 6)
* **Display Server:** (X11 or Wayland? Run `echo $XDG_SESSION_TYPE` to find out)
* **Steam Version:** (e.g., Stable Client, Beta Client)
* **Controller Model:** (e.g., Xbox Series X Controller, DualSense)
* **Connection Method:** (Bluetooth or USB)

**Logs**
```bash
journalctl --user -u steam-controller-handler.service -n 50 --no-pager
