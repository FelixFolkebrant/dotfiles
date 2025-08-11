#!/bin/bash

# Check network connection status using ip and iwgetid (more reliable)
# Check if we have an active WiFi connection
wifi_interface=$(ip route | grep default | grep -o 'wl[^ ]*' | head -1)
wifi_status=""
if [ -n "$wifi_interface" ]; then
    # Get WiFi network name using iwgetid
    wifi_status=$(iwgetid -r 2>/dev/null)
fi

# Check if we have an active ethernet connection
ethernet_interface=$(ip route | grep default | grep -o 'e[^ ]*' | head -1)

# Check VPN status
vpn_active=false
if pgrep openvpn >/dev/null 2>&1; then
    vpn_active=true
fi

# Determine what to display
if [ -n "$wifi_status" ]; then
    # WiFi is connected
    if [ "$vpn_active" = true ]; then
        # VPN is active - show VPN WiFi icon
        echo "{\"text\": \"󱚿\", \"tooltip\": \"$wifi_status (VPN)\"}"
    else
        # No VPN - show regular WiFi icon
        echo "{\"text\": \"󰖩\", \"tooltip\": \"$wifi_status\"}"
    fi
elif [ -n "$ethernet_interface" ]; then
    # Ethernet is connected
    if [ "$vpn_active" = true ]; then
        echo "{\"text\": \"󰈀\", \"tooltip\": \"Ethernet (VPN)\"}"
    else
        echo "{\"text\": \"󰈀\", \"tooltip\": \"Ethernet\"}"
    fi
else
    # No connection
    echo ""
fi
