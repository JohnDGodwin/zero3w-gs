#!/bin/bash


    echo "Starting AP mode..." > /run/pixelpilot.msg

    # Stop any existing wireless services that might interfere
    sudo systemctl stop wifibroadcast 2>/dev/null
    sudo systemctl stop hostapd 2>/dev/null
    sudo systemctl stop dnsmasq 2>/dev/null
    sleep 1

    # Ensure wlan0 is in a clean state
    sudo ip link set wlan0 down
    sleep 1
    sudo ip addr flush dev wlan0
    sleep 1

    # Configure network and verify
    sudo ip addr add 192.168.4.1/24 dev wlan0
    sleep 1
    
    # Verify IP assignment
    if ! ip addr show wlan0 | grep -q "192.168.4.1/24"; then
        echo "Failed to assign IP to wlan0" > /run/pixelpilot.msg
        return 1
    fi

    # Start hostapd and verify
    sudo systemctl start hostapd
    sleep 2
    if ! systemctl is-active --quiet hostapd; then
        echo "Failed to start hostapd" > /run/pixelpilot.msg
        return 1
    fi

    # Bring up interface
    sudo ip link set wlan0 up
    sleep 1
    if [[ $(ip link show wlan0 | grep -c "UP") -eq 0 ]]; then
        echo "Failed to bring up wlan0" > /run/pixelpilot.msg
        return 1
    fi

    # Start web UI
    cd /config/webUI
    sudo systemctl start webUI.service
    sleep 2
    
    # Start DHCP server and verify
    sudo systemctl start dnsmasq
    sleep 2
    if ! systemctl is-active --quiet dnsmasq; then
        echo "Failed to start dnsmasq" > /run/pixelpilot.msg
        return 1
    fi
    
    echo "AP mode on." > /run/pixelpilot.msg
    echo "AP mode started. Connect to 'RadxaGroundstation' network to access files."
    return 0
