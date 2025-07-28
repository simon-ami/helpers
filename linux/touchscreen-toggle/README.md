# Ubuntu Touchscreen Toggle

A robust solution to enable/disable touchscreen input on Ubuntu 22.04+ (works with both Wayland and X11).

**Most users:** Follow [Quick Setup](#quick-setup-standard-installation) → Test → Done!  
**If it doesn't work:** Follow [Custom Setup](#custom-setup-only-if-standard-setup-fails)

## Features

- ✅ **One-click toggle** - Desktop shortcut and terminal command
- ✅ **System notifications** - Toast messages with custom icon
- ✅ **Process management** - Prevents orphaned processes and handles cleanup
- ✅ **Desktop integration** - GUI password dialog for desktop shortcuts
- ✅ **Robust error handling** - Lock files prevent multiple instances
- ✅ **Cross-session compatibility** - Works in both Wayland and X11
- ✅ **Touchpad preservation** - Only disables touchscreen, keeps touchpad functional

## Quick Setup (Standard Installation)

**For most Ubuntu systems with ELAN touchscreens, follow these steps:**

### 1. Install Dependencies (Required)
```bash
sudo apt install evtest libnotify-bin
```

### 2. Install Scripts (Required)
```bash
# Copy files to correct locations
cp scripts/touchscreen-toggle.sh ~/
cp scripts/touchscreen-toggle-desktop.sh ~/
cp desktop-files/touchscreen-toggle.desktop ~/.local/share/applications/
cp desktop-files/touchscreen-toggle.desktop ~/Desktop/
cp assets/finger-touch.png ~/Downloads/

# Make scripts executable
chmod +x ~/touchscreen-toggle.sh
chmod +x ~/touchscreen-toggle-desktop.sh
chmod +x ~/Desktop/touchscreen-toggle.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

### 3. Test It Works (Required)
```bash
# Test the script - should work immediately on most systems
~/touchscreen-toggle.sh

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

### 2. Check Current Pattern Match
```bash
# Test if current pattern finds your devices
grep -E "[Tt]ouch.*[Ss]creen|ELAN2514.*" /proc/bus/input/devices

# If this returns nothing, you need custom configuration
```

### 3. Create Custom Device Pattern
```bash
# Edit the main script
nano ~/touchscreen-toggle.sh

# Find this line:
DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN2514.*"

# Replace with pattern matching YOUR devices, examples:
# For generic touchscreen: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen"
# For Wacom: DEVICE_PATTERN="[Ww]acom.*[Tt]ouch|[Tt]ouch.*[Ss]creen"  
# For different ELAN: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN1234.*"
# For Synaptics: DEVICE_PATTERN="[Ss]ynaptics.*[Tt]ouch|[Tt]ouch.*[Ss]creen"
```

### 4. Edit Desktop Wrapper Too
```bash
# Also edit the desktop wrapper script
nano ~/touchscreen-toggle-desktop.sh

# Find and update the same DEVICE_PATTERN line (around line 24)
```

### 5. Test Custom Configuration
```bash
# Test your custom pattern
grep -E "YourCustomPattern" /proc/bus/input/devices

# If it finds your touchscreen devices, test the script
~/touchscreen-toggle.sh
```

### 6. Verify evtest Access (If Still Not Working)
```bash
# Manual verification that evtest can access your devices
sudo evtest

# Look for your touchscreen in the numbered list
# Press Ctrl+C to exit
```

**⚠️ Important:** Always ensure your pattern excludes touchpad devices (avoid matching names with "Touchpad" or "Mouse")

## Usage

### Terminal
```bash
# Toggle touchscreen on/off
./touchscreen-toggle.sh
```

### Desktop
- **Double-click** desktop icon, or
- **Search** "Touchscreen Toggle" in applications menu

## How It Works

### Core Technology
- **`evtest --grab`** - Captures touchscreen input events to disable functionality
- **Background processes** - Maintains device grab until explicitly stopped
- **PID tracking** - Robust process management with cleanup

### Architecture
```
touchscreen-toggle.sh          # Main script (terminal use)
├── Direct sudo authentication
├── System notifications
└── Process management

touchscreen-toggle-desktop.sh  # Desktop wrapper
├── pkexec GUI authentication
├── User-session notifications
└── Temporary root script execution
```

### Process Flow
1. **Startup** - Cleanup orphaned processes, acquire lock
2. **Detection** - Find touchscreen devices via `/proc/bus/input/devices`
3. **Toggle** - Disable: spawn `evtest --grab` processes | Enable: kill tracked processes
4. **Notification** - Show system toast with status
5. **Cleanup** - Release lock, remove temporary files

## Files Structure

```
touchscreen-toggle/
├── README.md                           # This file
├── scripts/
│   ├── touchscreen-toggle.sh          # Main toggle script
│   └── touchscreen-toggle-desktop.sh  # Desktop wrapper with GUI auth
├── desktop-files/
│   └── touchscreen-toggle.desktop     # Desktop entry for shortcuts
└── assets/
    └── finger-touch.png               # Custom icon for notifications
```

## Installation Locations

| File | Destination | Purpose |
|------|-------------|---------|
| `touchscreen-toggle.sh` | `~/` | Main script for terminal use |
| `touchscreen-toggle-desktop.sh` | `~/` | Desktop wrapper for GUI auth |
| `touchscreen-toggle.desktop` | `~/.local/share/applications/` | Applications menu entry |
| `touchscreen-toggle.desktop` | `~/Desktop/` | Desktop shortcut |
| `finger-touch.png` | `~/Downloads/` | Icon for notifications |

## Dependencies

- **`evtest`** - Input device event interface
- **`libnotify-bin`** - Desktop notification system
- **`pkexec`** - GUI privilege escalation (pre-installed on Ubuntu)

## Troubleshooting

### Script says "No touchscreen devices found"
This means you need [Custom Setup](#custom-setup-only-if-standard-setup-fails) to configure your specific hardware.

### Desktop shortcut doesn't work but terminal does
```bash
# 1. Check file permissions
ls -la ~/touchscreen-toggle-desktop.sh
ls -la ~/Desktop/touchscreen-toggle.desktop

# 2. Test desktop wrapper manually
~/touchscreen-toggle-desktop.sh

# 3. If permissions wrong, fix them:
chmod +x ~/touchscreen-toggle-desktop.sh
chmod +x ~/Desktop/touchscreen-toggle.desktop
```

### Script hangs or multiple processes stuck
```bash
# Emergency cleanup - kills all evtest processes
sudo pkill -f "evtest --grab"
rm -f /tmp/touchscreen-toggle/touchscreen.pid

# Then test normally
~/touchscreen-toggle.sh
```

### Notifications don't appear
```bash
# Test notification system
notify-send "Test" "This is a test notification"

# If that doesn't work, install notification system:
sudo apt install libnotify-bin

# Check desktop environment supports notifications
echo $XDG_CURRENT_DESKTOP
```

### Touchpad also gets disabled
Your system likely has different hardware than expected. Follow [Custom Setup](#custom-setup-only-if-standard-setup-fails) to create a more specific device pattern that excludes your touchpad.

## Technical Details

### Device Detection Pattern
The script searches for devices matching: `[Tt]ouch.*[Ss]creen|ELAN2514.*`

This pattern specifically targets touchscreen devices while excluding touchpad:
- **Touchscreen devices:** ELAN2514 controller (touchscreen)
- **Excluded:** ELAN072D controller (touchpad/mouse)

Common touchscreen device names detected:
- `ELAN2514:00 04F3:2BEB` (main touchscreen)
- `ELAN2514:00 04F3:2BEB Stylus` (stylus input)
- `ELAN2514:00 04F3:2BEB UNKNOWN` (additional touchscreen interfaces)
- `Touchscreen` (generic touchscreen devices)
- `Multi-touch` (multi-touch displays)

### Process Management
- **Lock file**: `/tmp/touchscreen-toggle/touchscreen.lock`
- **PID file**: `/tmp/touchscreen-toggle/touchscreen.pid`
- **Cleanup**: Automatic on script exit, interrupt, or termination

### Security
- Scripts require `sudo` for device access
- Desktop wrapper uses `pkexec` for GUI authentication
- No passwords stored anywhere
- Minimal privilege requirements

## Advanced Configuration

### Custom Device Pattern
If your touchscreen isn't detected, customize the device pattern:

```bash
# 1. Find your exact device name
grep -i touch /proc/bus/input/devices

# 2. Edit the scripts to match your device
nano ~/touchscreen-toggle.sh
nano ~/touchscreen-toggle-desktop.sh

# 3. Modify this line in both scripts:
DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN2514.*"

# Examples for different devices:
# For Wacom touchscreen: DEVICE_PATTERN="[Ww]acom.*[Tt]ouch|[Tt]ouch.*[Ss]creen"
# For Synaptics touchscreen: DEVICE_PATTERN="[Ss]ynaptics.*[Tt]ouch|[Tt]ouch.*[Ss]creen"
# For different ELAN models: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN1234.*"
# For generic touchscreen only: DEVICE_PATTERN="[Tt]ouch.*[Ss]creen"
# 
# IMPORTANT: Always exclude touchpad patterns like:
# - Avoid matching devices with "Touchpad" or "Mouse" in their names
# - Use specific controller IDs (like ELAN2514) rather than broad patterns
```

### Custom Icon
Replace `~/Downloads/finger-touch.png` with your preferred icon (PNG format recommended).

### Different Install Locations
Edit paths in desktop files if using different script locations:
```bash
# Edit desktop entry
nano ~/.local/share/applications/touchscreen-toggle.desktop
# Change Exec= and Icon= paths as needed
```

---

## Credits

- **Icon:** <a href="https://www.flaticon.com/free-icons/tap" title="tap icons">Tap icons created by kerismaker - Flaticon</a>

---

**Tested on:** Ubuntu 22.04+ (Wayland/X11)  
**Requirements:** `bash`, `evtest`, `libnotify-bin`, `pkexec`  
**License:** MIT