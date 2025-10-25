# Linux Touchscreen Toggle

A robust solution to enable/disable touchscreen input on Linux systems.

## Supported Distributions

This repository contains versions for different Linux distributions:

### 🔵 **Arch Linux** (Hyprland/Wayland)
- Location: `arch/`
- Package manager: `pacman`
- Desktop environment: Hyprland (Wayland)
- See: [arch/README.md](arch/README.md)

### 🟠 **Ubuntu** (GNOME/Wayland/X11)
- Location: `ubuntu/`
- Package manager: `apt`
- Desktop environments: GNOME (Wayland/X11)
- See: [ubuntu/README.md](ubuntu/README.md)

## Features

- **Desktop shortcut & terminal command** - One-click toggle from anywhere
- **System notifications** - Visual feedback when toggling
- **Touchpad preservation** - Only disables touchscreen, keeps touchpad functional
- **Wayland/X11 compatible** - Works on both display servers

## Quick Start

1. Navigate to your distribution's directory:
   - **Arch Linux:** `cd arch/`
   - **Ubuntu:** `cd ubuntu/`

2. Follow the installation instructions in the respective README

## Repository Structure

```
touchscreen-toggle/
├── README.md                 # This file
├── assets/                   # Shared assets (icons)
│   └── finger-touch.png
├── arch/                     # Arch Linux version
│   ├── README.md
│   ├── scripts/
│   │   └── touchscreen-toggle
│   └── desktop-files/
│       └── touchscreen-toggle.desktop
└── ubuntu/                   # Ubuntu version
    ├── README.md
    ├── scripts/
    │   ├── touchscreen-toggle.sh
    │   └── touchscreen-toggle-desktop.sh
    └── desktop-files/
        └── touchscreen-toggle.desktop
```

## How It Works

Both versions use the same core technique:
- Uses `evtest --grab` to capture and suppress touchscreen input events
- Preserves touchpad functionality
- Stores process IDs for cleanup when re-enabling
- Provides desktop notifications for user feedback

## Credits

- **Core technique:** Based on [chimeraha's AskUbuntu answer](https://askubuntu.com/a/1412240)
- **Icon:** [Tap icons created by kerismaker - Flaticon](https://www.flaticon.com/free-icons/tap)

## License

MIT
