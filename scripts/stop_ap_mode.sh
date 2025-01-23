#!/bin/bash

    echo "Stopping AP mode..." > /run/pixelpilot.msg
    echo "Stopping AP mode..."
    sudo systemctl stop webUI.service
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    
    sudo ip link set wlan0 down
    sudo ip addr flush dev wlan0
    
    echo "AP mode off." > /run/pixelpilot.msg
