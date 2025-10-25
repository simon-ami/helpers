#!/bin/bash

# Desktop wrapper for touchscreen toggle script
# Uses pkexec for GUI privilege escalation and handles notifications in user session

SCRIPT_PATH="/home/simon/touchscreen-toggle.sh"
ICON_PATH="/home/simon/Downloads/finger-touch.png"

# Check if the main script exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    notify-send --icon="dialog-error" --app-name="Touchscreen Toggle" "Error" "Main script not found!"
    exit 1
fi

# Create a temporary script that suppresses notifications and just returns status codes
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash

# Simple Touchscreen Toggle Script for Ubuntu 22.04+ (Wayland/X11)
# Desktop version - no notifications, just exit codes

PID_DIR="/tmp/touchscreen-toggle"
DEVICE_PATTERN="[Tt]ouch.*[Ss]creen|ELAN2514.*"
LOCK_FILE="$PID_DIR/touchscreen.lock"

# Create PID directory if it doesn't exist
mkdir -p "$PID_DIR"

# Function to show notification - DISABLED for desktop version
show_notification() {
    return 0
}

# Function to cleanup orphaned processes
cleanup_orphaned_processes() {
    # Only clean up if PID file exists but processes are dead
    if [[ -f "$PID_DIR/touchscreen.pid" ]]; then
        local has_live_processes=false
        
        while IFS= read -r pid; do
            # Skip comment lines and empty lines
            if [[ -n "$pid" && ! "$pid" =~ ^# ]]; then
                if kill -0 "$pid" 2>/dev/null; then
                    has_live_processes=true
                    break
                fi
            fi
        done < "$PID_DIR/touchscreen.pid"
        
        # If no live processes but PID file exists, clean up orphaned entries
        if [[ "$has_live_processes" == "false" ]]; then
            rm -f "$PID_DIR/touchscreen.pid"
        fi
    fi
    
    # Always remove stale lock files
    rm -f "$LOCK_FILE"
}

# Function to acquire lock (prevent multiple instances)
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
            exit 2  # Another instance running
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

# Function to release lock
release_lock() {
    rm -f "$LOCK_FILE"
}

# Trap to ensure cleanup on exit
trap 'release_lock' EXIT INT TERM

# Function to find touchscreen devices
find_touchscreen_devices() {
    local devices=()
    local filename='/proc/bus/input/devices'
    local inside=0
    local regex='event([0-9]+)'
    
    while IFS= read -r line; do
        if [[ $line =~ $DEVICE_PATTERN ]]; then 
            inside=1
        fi
        
        if [[ $line =~ $regex ]] && [[ "$inside" -eq 1 ]]; then
            devices+=("${BASH_REMATCH[1]}")
            inside=0
        fi
    done < "$filename"
    
    printf '%s\n' "${devices[@]}"
}

# Function to check if touchscreen is currently disabled
is_disabled() {
    [[ -f "$PID_DIR/touchscreen.pid" ]]
}

# Function to disable touchscreen
disable_touchscreen() {
    local devices=($(find_touchscreen_devices))
    
    if [[ ${#devices[@]} -eq 0 ]]; then
        exit 3  # No devices found
    fi
    
    local pids=()
    local success=false
    
    for event_num in "${devices[@]}"; do
        local device_path="/dev/input/event${event_num}"
        if [[ -e "$device_path" ]]; then
            evtest --grab "$device_path" >/dev/null 2>&1 &
            local pid=$!
            # Verify the process actually started
            sleep 0.1
            if kill -0 "$pid" 2>/dev/null; then
                pids+=("$pid")
                success=true
            fi
        fi
    done
    
    if [[ "$success" == "true" && ${#pids[@]} -gt 0 ]]; then
        # Save PIDs to file with timestamp for debugging
        {
            echo "# Created: $(date)"
            printf '%s\n' "${pids[@]}"
        } > "$PID_DIR/touchscreen.pid"
        exit 0  # Successfully disabled
    else
        exit 4  # Failed to disable
    fi
}

# Function to enable touchscreen
enable_touchscreen() {
    if [[ ! -f "$PID_DIR/touchscreen.pid" ]]; then
        exit 1  # Already enabled
    fi
    
    local killed=false
    while IFS= read -r pid; do
        # Skip comment lines and empty lines
        if [[ -n "$pid" && ! "$pid" =~ ^# ]]; then
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null && killed=true
            fi
        fi
    done < "$PID_DIR/touchscreen.pid"
    
    # Always clean up the PID file
    rm -f "$PID_DIR/touchscreen.pid"
    
    if [[ "$killed" == "true" ]]; then
        exit 0  # Successfully enabled
    else
        exit 1  # Was already enabled
    fi
}

# Initialize script - cleanup orphaned processes and acquire lock
cleanup_orphaned_processes
acquire_lock

# Main logic
if is_disabled; then
    enable_touchscreen
else
    disable_touchscreen
fi
EOF

chmod +x "$TEMP_SCRIPT"

# Run the temporary script with pkexec and capture the exit code
pkexec "$TEMP_SCRIPT"
exit_code=$?

# Clean up the temporary script
rm -f "$TEMP_SCRIPT"

# Handle notifications in user session based on exit code
case $exit_code in
    0)
        if [[ -f "/tmp/touchscreen-toggle/touchscreen.pid" ]]; then
            notify-send --icon="$ICON_PATH" --app-name="Touchscreen Toggle" "Touchscreen Disabled" "Touchscreen input has been disabled"
        else
            notify-send --icon="$ICON_PATH" --app-name="Touchscreen Toggle" "Touchscreen Enabled" "Touchscreen input has been enabled"
        fi
        ;;
    1)
        notify-send --icon="$ICON_PATH" --app-name="Touchscreen Toggle" "Already Enabled" "Touchscreen is already enabled"
        ;;
    2)
        notify-send --icon="dialog-error" --app-name="Touchscreen Toggle" "Error" "Another instance is already running"
        ;;
    3)
        notify-send --icon="dialog-error" --app-name="Touchscreen Toggle" "Error" "No touchscreen devices found!"
        ;;
    4)
        notify-send --icon="dialog-error" --app-name="Touchscreen Toggle" "Error" "Failed to disable touchscreen"
        ;;
    *)
        notify-send --icon="dialog-error" --app-name="Touchscreen Toggle" "Error" "Unknown error occurred"
        ;;
esac