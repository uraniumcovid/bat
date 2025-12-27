#!/run/current-system/sw/bin/bash

# Get battery percentage
battery_path="/sys/class/power_supply/macsmc-battery/capacity"
if [ -f "$battery_path" ]; then
    battery=$(cat "$battery_path")
else
    # Try common battery paths
    for bat_path in /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/*/capacity; do
        if [ -f "$bat_path" ]; then
            battery=$(cat "$bat_path")
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
        wifi_network="connected"
    else
        wifi_network="disconnected"
    fi
fi

# Add battery warning indicator
battery_warning=""
if [ "$battery" != "N/A" ] && [ "$battery" -le 20 ]; then
    if [ "$battery" -le 10 ]; then
        battery_warning=" ⚠️ CRITICAL"
    else
        battery_warning=" ⚠️ LOW"
    fi
fi

# Print battery, date, and wifi network
echo "battery: ${battery}%${battery_warning}, ${datetime}, ${wifi_network}"
