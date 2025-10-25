# Arch Linux Touchscreen Toggle

A simple solution to enable/disable touchscreen input on Arch Linux with Hyprland (Wayland).

## Features

- **Terminal command** - Toggle from anywhere via `touchscreen-toggle`
- **Desktop shortcut** - One-click toggle from application launcher
- **System notifications** - Visual feedback when toggling
- **Touchpad preservation** - Only disables touchscreen, keeps touchpad functional
- **Wayland compatible** - Works with Hyprland and other Wayland compositors

## Quick Setup

### 1. Install Dependencies (Required)
```bash
sudo pacman -S evtest libnotify
```

### 2. Install Scripts (Required)
```bash
# Copy script to local bin
cp scripts/touchscreen-toggle ~/.local/bin/
chmod +x ~/.local/bin/touchscreen-toggle

# Copy desktop file and icon
cp desktop-files/touchscreen-toggle.desktop ~/.local/share/applications/
mkdir -p ~/.local/share/applications/icons/
cp ../assets/finger-touch.png ~/.local/share/applications/icons/

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

### 3. Test It Works (Required)
```bash
# Test the script - should work immediately on most systems
touchscreen-toggle

# Expected output: "Touchscreen Disabled: Touchscreen input has been disabled"
# Run again: "Touchscreen Enabled: Touchscreen input has been enabled"
```

**✅ If the test works, you're done! The desktop shortcut should also work.**

---

## Custom Setup (Only if Standard Setup Fails)

**If the script says "No touchscreen devices found" or doesn't work, follow these steps:**

### 1. Identify Your Touchscreen Devices
```bash
# Find touchscreen devices on your system
grep -E "[Tt]ouch|ELAN|[Ss]ynaptics|[Ww]acom" /proc/bus/input/devices

# Look for lines like:
# N: Name="Your-Touchscreen-Device-Name"
```

### 2. Create Custom Device Pattern
```bash
# Edit the script
nano ~/.local/bin/touchscreen-toggle

# Find this line (around line 7):
DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN2514.*"

# Replace with pattern matching YOUR devices, examples:
# For generic touchscreen: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen"
# For Wacom: DEVICE_PATTERN="[Ww]acom.*[Tt]ouch|[Tt]ouch.*[Ss]creen"
# For different ELAN: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN1234.*"
# For Synaptics: DEVICE_PATTERN="[Ss]ynaptics.*[Tt]ouch|[Tt]ouch.*[Ss]creen"
```

**⚠️ Important:** Always ensure your pattern excludes touchpad devices (avoid matching names with "Touchpad" or "Mouse")

## Usage

### Terminal
```bash
# Toggle touchscreen on/off
touchscreen-toggle
```

### Desktop
- **Search** "Touchscreen Toggle" in application launcher (Walker, Rofi, etc.)

## Dependencies

- **`evtest`** - Input device event interface (pacman package)
- **`libnotify`** - Desktop notification system (pacman package)
- **`sudo`** - Required for device access

## Troubleshooting

### Script says "No touchscreen devices found"
This means you need [Custom Setup](#custom-setup-only-if-standard-setup-fails) to configure your specific hardware.

### Desktop shortcut doesn't work but terminal does
```bash
# 1. Check file permissions
ls -la ~/.local/bin/touchscreen-toggle
ls -la ~/.local/share/applications/touchscreen-toggle.desktop

# 2. If permissions wrong, fix them:
chmod +x ~/.local/bin/touchscreen-toggle
```

### Script hangs or multiple processes stuck
```bash
# Emergency cleanup - kills all evtest processes
sudo pkill -f "evtest --grab"
rm -f /tmp/touchscreen-toggle/touchscreen.pid

# Then test normally
touchscreen-toggle
```

### Notifications don't appear
```bash
# Test notification system
notify-send "Test" "This is a test notification"

# If that doesn't work, install notification system:
sudo pacman -S libnotify

# Check if mako or dunst is running
pgrep -a mako
pgrep -a dunst
```

### Touchpad also gets disabled
Your system likely has different hardware than expected. Follow [Custom Setup](#custom-setup-only-if-standard-setup-fails) to create a more specific device pattern that excludes your touchpad.

## Custom Icon
Replace `~/.local/share/applications/icons/finger-touch.png` with your preferred icon (PNG format recommended).

---

## Credits

- **Core technique:** Based on [chimeraha's AskUbuntu answer](https://askubuntu.com/a/1412240) using `evtest --grab` to disable touchscreen
- **Icon:** <a href="https://www.flaticon.com/free-icons/tap" title="tap icons">Tap icons created by kerismaker - Flaticon</a>

---

**Tested on:** Arch Linux with Hyprland 0.51.1 (Wayland)
**Requirements:** `bash`, `evtest`, `libnotify`, `sudo`
**License:** MIT
