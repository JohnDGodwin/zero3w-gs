#!/bin/bash

DVR_PATH=/media
SCREEN_MODE=$(grep "^mode = " /config/scripts/screen-mode | cut -d'=' -f2 | tr -d ' ')
REC_FPS=$(grep "^fps = " /config/scripts/rec-fps | cut -d'=' -f2 | tr -d ' ')
OSD=$(grep "^render = " /config/scripts/osd | cut -d'=' -f2 | tr -d ' ')
PID=0
AP_MODE=0
LONG_PRESS_DURATION=4  # Duration in seconds for long press

# Button GPIO assignments
DVR_BUTTON=`gpiofind PIN_32`

# Function to start AP mode
start_ap_mode() {
    echo "Starting AP mode..." > /run/pixelpilot.msg
    echo "Stopping wifibroadcast service..."
    sudo systemctl stop wifibroadcast
    sudo systemctl stop wifibroadcast@gs

    # Configure internal WiFi for AP mode
    sudo ip link set wlan0 down
    sudo ip addr flush dev wlan0

    # Configure network
    sudo ip addr add 192.168.4.1/24 dev wlan0

    # Start services
    sudo systemctl start hostapd
    sudo ip link set wlan0 up
    cd /config/wfb_plotter
    sudo python3 /config/wfb_plotter/plotter.py &
    
    # Start DHCP server
    sudo systemctl start dnsmasq
    
    AP_MODE=1
    echo "AP mode started." > /run/pixelpilot.msg
    echo "AP mode started. Connect to 'RadxaGroundstation' network to access files."
}

# Function to stop AP mode and restore wifibroadcast
stop_ap_mode() {
    echo "Stopping AP mode..." > /run/pixelpilot.msg
    echo "Stopping AP mode..."
    sudo pkill -f "python3 /config/wfb_plotter/plotter.py"
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    
    sudo ip link set wlan0 down
    sudo ip addr flush dev wlan0
    
    # Restart wifibroadcast service
    sudo systemctl start wifibroadcast
    sudo systemctl start wifibroadcast@gs
    AP_MODE=0
    echo "Wifibroadcast restored." > /run/pixelpilot.msg
    echo "Wifibroadcast mode restored."
}

FILE="/etc/default/wifibroadcast"

#Ensure WFB-ng is setup and NICs are available
if [[ -f "$FILE" ]]; then
    NIC_NAMES=$(grep -oP '^WFB_NICS="\K[^"]+' "$FILE")
    if [[ -n "$NIC_NAMES" ]]; then
        NICS=($NIC_NAMES)
    else
        echo "No NIC names found in WFB_NICS variable. Exiting."
        exit 1
    fi
else
    echo "File $FILE not found. Exiting."
    exit 1
fi

#Start PixelPilot
pixelpilot --osd --osd-elements 0 --osd-custom-message --osd-config /config/scripts/osd.json --screen-mode $SCREEN_MODE --dvr-framerate $REC_FPS --dvr-fmp4 --dvr-template $DVR_PATH/record_%Y-%m-%d_%H-%M-%S.mp4 &
PID=$!

#Start MSPOSD on gs-side
if [[ "$OSD" == "ground" ]]; then
    # Wait for IP to become available, with timeout
    max_attempts=30  # 30 attempts = 60 seconds with 2 second sleep
    attempt=1
    
    echo "Waiting for 10.5.0.1 to become available..."
    while ! ping -c 1 -W 1 10.5.0.1 >/dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            exit 1
        fi
        sleep 2
        ((attempt++))
    done
    
    echo "IP 10.5.0.1 is available, starting msposd_rockchip"
    msposd_rockchip --osd --ahi 0 --matrix 11 -v -r 5 --master 10.5.0.1:5000 &
fi

# Variables for button press timing
dvr_press_start=0

#Begin monitoring gpio for button presses
echo "Monitoring buttons"

while true; do
        DVR_BUTTON_STATE=$(gpioget $DVR_BUTTON)
        
        # Handle DVR button long press
        if [ "$DVR_BUTTON_STATE" -eq 1 ]; then
            if [ "$dvr_press_start" -eq 0 ]; then
                dvr_press_start=$(date +%s)
            else
                current_time=$(date +%s)
                elapsed=$((current_time - dvr_press_start))
                
                if [ "$elapsed" -ge "$LONG_PRESS_DURATION" ]; then
                    if [ "$AP_MODE" -eq 0 ]; then
                        start_ap_mode
                    else
                        stop_ap_mode
                    fi
                    dvr_press_start=0
                    sleep 1
                fi
            fi
        fi

        # Regular button handling (only when not in AP mode)
        if [ "$AP_MODE" -eq 0 ]; then
            if [ "$DVR_BUTTON_STATE" -eq 1 ]; then
                echo "toggle DVR for $PID"
                kill -SIGUSR1 $PID
                sleep 1
            fi
        fi
        sleep 0.1
done
