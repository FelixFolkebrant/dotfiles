#!/usr/bin/env bash

set -u

# wireless_tools/iwgetid is no longer installed by default. NetworkManager is
# already used by nmtui, so query the active connection through nmcli.
wifi_status=$(nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null |
  awk -F: '$1 == "wifi" && $2 == "connected" { print $3; exit }')
ethernet_status=$(nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null |
  awk -F: '$1 == "ethernet" && $2 == "connected" { print $3; exit }')

json_escape() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    printf '%s' "$value"
}

wifi_status=$(json_escape "$wifi_status")

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
elif [ -n "$ethernet_status" ]; then
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
