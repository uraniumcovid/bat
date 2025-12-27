#!/run/current-system/sw/bin/bash

# Get battery percentage and status
battery_path="/sys/class/power_supply/macsmc-battery/capacity"
status_path="/sys/class/power_supply/macsmc-battery/status"

if [ -f "$battery_path" ]; then
    battery=$(cat "$battery_path")
    if [ -f "$status_path" ]; then
        battery_status=$(cat "$status_path")
    fi
else
    # Try common battery paths
    for bat_dir in /sys/class/power_supply/BAT* /sys/class/power_supply/macsmc-battery; do
        if [ -f "$bat_dir/capacity" ]; then
            battery=$(cat "$bat_dir/capacity")
            if [ -f "$bat_dir/status" ]; then
                battery_status=$(cat "$bat_dir/status")
            fi
            break
        fi
    done
    
    # Fallback if no battery found
    if [ -z "$battery" ]; then
        battery="N/A"
    fi
fi

# Get current date and time
datetime=$(date '+%Y-%m-%d %H:%M')

# Get wifi network name
wifi_network=$(nmcli -t -f ACTIVE,SSID device wifi | grep '^yes:' | cut -d: -f2 2>/dev/null)
if [ -z "$wifi_network" ]; then
    # Try alternative method with iwgetid if available
    wifi_network=$(iwgetid -r 2>/dev/null)
fi
if [ -z "$wifi_network" ]; then
    # Check if wlan0 is up as fallback
    if ip link show wlan0 2>/dev/null | grep -q "state UP"; then
        wifi_network="wifi connected"
    else
        wifi_network="wifi disconnected"
    fi
fi

# Add battery warning and charging indicators
battery_warning=""
charging_indicator=""

if [ "$battery" != "N/A" ] && [ "$battery" -le 20 ]; then
    if [ "$battery" -le 10 ]; then
        battery_warning=" ⚠️ CRITICAL"
    else
        battery_warning=" ⚠️ LOW"
    fi
fi

if [ "$battery_status" = "Charging" ]; then
    charging_indicator=" (charging)"
fi

# Print battery, date, and wifi network
echo "battery: ${battery}%${battery_warning}${charging_indicator}, ${datetime}, ${wifi_network}"
