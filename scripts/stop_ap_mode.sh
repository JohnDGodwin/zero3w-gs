#!/bin/bash

    echo "Stopping AP mode..." > /run/pixelpilot.msg
    echo "Stopping AP mode..."
    sudo pkill -f "python3 /config/webUI/app.py"
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    
    sudo ip link set wlan0 down
    sudo ip addr flush dev wlan0
    
    echo "AP mode off." > /run/pixelpilot.msg
    return 0
