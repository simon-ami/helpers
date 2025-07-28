# Ubuntu Touchscreen Toggle

A robust solution to enable/disable touchscreen input on Ubuntu 22.04+ (works with both Wayland and X11).

## Features

- ✅ **One-click toggle** - Desktop shortcut and terminal command
- ✅ **System notifications** - Toast messages with custom icon
- ✅ **Process management** - Prevents orphaned processes and handles cleanup
- ✅ **Desktop integration** - GUI password dialog for desktop shortcuts
- ✅ **Robust error handling** - Lock files prevent multiple instances
- ✅ **Cross-session compatibility** - Works in both Wayland and X11

## Quick Install

```bash
# 1. Copy files to correct locations
cp scripts/touchscreen-toggle.sh ~/
cp scripts/touchscreen-toggle-desktop.sh ~/
cp desktop-files/touchscreen-toggle.desktop ~/.local/share/applications/
cp desktop-files/touchscreen-toggle.desktop ~/Desktop/
cp assets/finger-touch.png ~/Downloads/

# 2. Make scripts executable
chmod +x ~/touchscreen-toggle.sh
chmod +x ~/touchscreen-toggle-desktop.sh
chmod +x ~/Desktop/touchscreen-toggle.desktop

# 3. Update desktop database
update-desktop-database ~/.local/share/applications/

# 4. Install dependencies
sudo apt install evtest libnotify-bin
```

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
```bash
# Check for touchscreen devices
grep -i touch /proc/bus/input/devices
```

### Desktop shortcut doesn't work
```bash
# Verify file permissions
ls -la ~/touchscreen-toggle-desktop.sh
ls -la ~/Desktop/touchscreen-toggle.desktop

# Test desktop wrapper manually
~/touchscreen-toggle-desktop.sh
```

### Multiple processes stuck
```bash
# Manual cleanup
sudo pkill -f "evtest --grab"
rm -f /tmp/touchscreen-toggle/touchscreen.pid
```

### Notifications don't appear
```bash
# Test notification system
notify-send "Test" "This is a test notification"

# Check if notify-send is installed
which notify-send
```

## Technical Details

### Device Detection Pattern
The script searches for devices matching: `[Tt]ouch.*[Ss]creen|ELAN.*:.*`

Common touchscreen device names:
- `ELAN2514:00 04F3:2BEB`
- `Touchscreen`
- `Multi-touch`

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

**Tested on:** Ubuntu 22.04+ (Wayland/X11)  
**Requirements:** `bash`, `evtest`, `libnotify-bin`, `pkexec`  
**License:** MIT